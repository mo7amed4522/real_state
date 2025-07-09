package services

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"time"

	"go-chat-service/database"
	"go-chat-service/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ChatService struct{}

func NewChatService() *ChatService {
	return &ChatService{}
}

// GetOrCreateConversation creates a conversation between two users or returns existing one
func (s *ChatService) GetOrCreateConversation(user1ID, user2ID uuid.UUID) (*models.Conversation, error) {
	var conversation models.Conversation

	// Check if conversation already exists
	err := database.DB.Where(
		"(participant1_id = ? AND participant2_id = ?) OR (participant1_id = ? AND participant2_id = ?)",
		user1ID, user2ID, user2ID, user1ID,
	).Preload("Participant1").Preload("Participant2").First(&conversation).Error

	if err == nil {
		return &conversation, nil
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	// Create new conversation
	conversation = models.Conversation{
		Participant1ID: user1ID,
		Participant2ID: user2ID,
	}

	err = database.DB.Create(&conversation).Error
	if err != nil {
		return nil, err
	}

	// Load participants
	err = database.DB.Preload("Participant1").Preload("Participant2").First(&conversation, conversation.ID).Error
	return &conversation, err
}

// SendMessage sends a message in a conversation
func (s *ChatService) SendMessage(conversationID, senderID uuid.UUID, content string, messageType models.MessageType) (*models.Message, error) {
	// If messageType is file/image/voice, content should be a URL
	message := models.Message{
		ConversationID: conversationID,
		SenderID:       senderID,
		Content:        content, // URL or text
		MessageType:    messageType,
	}

	err := database.DB.Create(&message).Error
	if err != nil {
		return nil, err
	}

	// Update conversation's last message
	err = database.DB.Model(&models.Conversation{}).Where("id = ?", conversationID).Update("last_message_id", message.ID).Error
	if err != nil {
		return nil, err
	}

	// Load sender information
	err = database.DB.Preload("Sender").First(&message, message.ID).Error
	if err != nil {
		return nil, err
	}

	// Save to Redis (append to chat:messages:<conversationId> list)
	redisKey := "chat:messages:" + conversationID.String()
	msgJson, err := json.Marshal(message)
	if err == nil {
		err = database.RedisClient.RPush(context.Background(), redisKey, msgJson).Err()
		if err != nil {
			log.Printf("error saving chat message to Redis: %v", err)
		}
		// Set expiration (TTL) to 30 days on the key
		expireErr := database.RedisClient.Expire(context.Background(), redisKey, 30*24*time.Hour).Err()
		if expireErr != nil {
			log.Printf("error setting expiration on chat message key in Redis: %v", expireErr)
		}
	} else {
		log.Printf("error marshaling chat message for Redis: %v", err)
	}

	return &message, nil
}

// GetConversationMessages gets all messages in a conversation
func (s *ChatService) GetConversationMessages(conversationID uuid.UUID, limit, offset int) ([]models.Message, error) {
	var messages []models.Message

	query := database.DB.Where("conversation_id = ?", conversationID).
		Preload("Sender").
		Order("created_at DESC")

	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}

	err := query.Find(&messages).Error
	return messages, err
}

// GetUserConversations gets all conversations for a user
func (s *ChatService) GetUserConversations(userID uuid.UUID) ([]models.Conversation, error) {
	var conversations []models.Conversation

	err := database.DB.Where("participant1_id = ? OR participant2_id = ?", userID, userID).
		Preload("Participant1").
		Preload("Participant2").
		Preload("LastMessage").
		Preload("LastMessage.Sender").
		Order("updated_at DESC").
		Find(&conversations).Error

	return conversations, err
}

// MarkMessageAsRead marks a message as read
func (s *ChatService) MarkMessageAsRead(messageID uuid.UUID) error {
	return database.DB.Model(&models.Message{}).Where("id = ?", messageID).Update("is_read", true).Error
}

// MarkConversationAsRead marks all messages in a conversation as read for a specific user
func (s *ChatService) MarkConversationAsRead(conversationID, userID uuid.UUID) error {
	return database.DB.Model(&models.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND is_read = false", conversationID, userID).
		Update("is_read", true).Error
}

// GetUnreadMessageCount gets the number of unread messages for a user
func (s *ChatService) GetUnreadMessageCount(userID uuid.UUID) (int64, error) {
	var count int64

	// Get conversations where user is a participant
	var conversationIDs []uuid.UUID
	err := database.DB.Model(&models.Conversation{}).
		Where("participant1_id = ? OR participant2_id = ?", userID, userID).
		Pluck("id", &conversationIDs).Error

	if err != nil {
		return 0, err
	}

	if len(conversationIDs) == 0 {
		return 0, nil
	}

	err = database.DB.Model(&models.Message{}).
		Where("conversation_id IN ? AND sender_id != ? AND is_read = false", conversationIDs, userID).
		Count(&count).Error

	return count, err
}

// GetConversationMessagesFromRedis tries to get messages from Redis, falls back to DB if not found
func (s *ChatService) GetConversationMessagesFromRedis(conversationID uuid.UUID, limit, offset int) ([]models.Message, error) {
	ctx := context.Background()
	redisKey := "chat:messages:" + conversationID.String()

	// Get all messages from Redis (or use limit/offset as needed)
	msgs, err := database.RedisClient.LRange(ctx, redisKey, int64(offset), int64(offset+limit-1)).Result()
	if err != nil {
		return nil, err
	}
	if len(msgs) == 0 {
		// Fallback to DB
		return s.GetConversationMessages(conversationID, limit, offset)
	}

	var messages []models.Message
	for _, msgStr := range msgs {
		var msg models.Message
		if err := json.Unmarshal([]byte(msgStr), &msg); err == nil {
			messages = append(messages, msg)
		}
	}
	return messages, nil
}

// GetMessageCountFromRedis returns the number of messages in a conversation from Redis
func (s *ChatService) GetMessageCountFromRedis(conversationID uuid.UUID) (int64, error) {
	ctx := context.Background()
	redisKey := "chat:messages:" + conversationID.String()
	return database.RedisClient.LLen(ctx, redisKey).Result()
}

// GetMessageCountFromDB returns the number of messages in a conversation from the database
func (s *ChatService) GetMessageCountFromDB(conversationID uuid.UUID) (int64, error) {
	var count int64
	err := database.DB.Model(&models.Message{}).Where("conversation_id = ?", conversationID).Count(&count).Error
	return count, err
}

// GetFileBlobFromRedis retrieves a file's binary data from Redis by key
func GetFileBlobFromRedis(key string) ([]byte, error) {
	ctx := context.Background()
	return database.RedisClient.Get(ctx, key).Bytes()
}

// StoreFileBlobInRedis stores a file's binary data in Redis under the given key
func StoreFileBlobInRedis(key string, data []byte) error {
	ctx := context.Background()
	return database.RedisClient.Set(ctx, key, data, 0).Err()
}
