package handlers

import (
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"go-chat-service/models"
	"go-chat-service/services"
	"go-chat-service/utils"
	"io/ioutil"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ChatHandler struct {
	chatService *services.ChatService
	userService *services.UserService
}

func NewChatHandler(chatService *services.ChatService, userService *services.UserService) *ChatHandler {
	return &ChatHandler{
		chatService: chatService,
		userService: userService,
	}
}

// GetUserConversations gets all conversations for a user
func (h *ChatHandler) GetUserConversations(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	conversations, err := h.chatService.GetUserConversations(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"conversations": conversations,
	})
}

// GetConversationMessages gets messages in a conversation
func (h *ChatHandler) GetConversationMessages(c *gin.Context) {
	conversationIDStr := c.Param("conversation_id")
	conversationID, err := uuid.Parse(conversationIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation ID"})
		return
	}

	limitStr := c.DefaultQuery("limit", "50")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		limit = 50
	}

	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		offset = 0
	}

	// Use Redis-backed method for fast retrieval
	messages, err := h.chatService.GetConversationMessagesFromRedis(conversationID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Determine total count for hasMore
	totalCount, err := h.chatService.GetMessageCountFromRedis(conversationID)
	if err != nil || totalCount == 0 {
		totalCount, err = h.chatService.GetMessageCountFromDB(conversationID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	hasMore := int64(offset+len(messages)) < totalCount

	c.JSON(http.StatusOK, gin.H{
		"messages": messages,
		"hasMore":  hasMore,
	})
}

// SendMessage sends a message in a conversation
func (h *ChatHandler) SendMessage(c *gin.Context) {
	var request struct {
		ConversationID string `json:"conversationId" binding:"required"`
		SenderID       string `json:"senderId" binding:"required"`
		Content        string `json:"content" binding:"required"`
		MessageType    string `json:"messageType"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	conversationID, err := uuid.Parse(request.ConversationID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation ID"})
		return
	}

	senderID, err := uuid.Parse(request.SenderID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid sender ID"})
		return
	}

	messageType := models.MessageTypeText
	if request.MessageType != "" {
		messageType = models.MessageType(request.MessageType)
	}

	message, err := h.chatService.SendMessage(conversationID, senderID, request.Content, messageType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": message,
	})
}

// CreateConversation creates a new conversation between two users
func (h *ChatHandler) CreateConversation(c *gin.Context) {
	var request struct {
		User1ID string `json:"user1Id" binding:"required"`
		User2ID string `json:"user2Id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user1ID, err := uuid.Parse(request.User1ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user1 ID"})
		return
	}

	user2ID, err := uuid.Parse(request.User2ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user2 ID"})
		return
	}

	conversation, err := h.chatService.GetOrCreateConversation(user1ID, user2ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"conversation": conversation,
	})
}

// MarkConversationAsRead marks all messages in a conversation as read
func (h *ChatHandler) MarkConversationAsRead(c *gin.Context) {
	conversationIDStr := c.Param("conversation_id")
	userIDStr := c.Query("user_id")

	conversationID, err := uuid.Parse(conversationIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation ID"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	err = h.chatService.MarkConversationAsRead(conversationID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Conversation marked as read"})
}

// GetUnreadMessageCount gets the number of unread messages for a user
func (h *ChatHandler) GetUnreadMessageCount(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	count, err := h.chatService.GetUnreadMessageCount(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"unreadCount": count,
	})
}

// UploadFile handles file/image/audio upload for a conversation
func (h *ChatHandler) UploadFile(c *gin.Context) {
	conversationID := c.Param("conversation_id")
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}
	defer file.Close()

	// Validate file (extension, magic bytes, size)
	if err := utils.ValidateFile(header, file); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Save file to disk
	dir := filepath.Join("uploads", conversationID)
	if err := os.MkdirAll(dir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create upload directory"})
		return
	}

	filename := header.Filename
	filePath := filepath.Join(dir, filename)
	out, err := os.Create(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}
	defer out.Close()
	if _, err := io.Copy(out, file); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to write file"})
		return
	}

	// Read file bytes for Redis storage
	fileBytes, err := ioutil.ReadFile(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read file for Redis storage"})
		return
	}
	redisKey := "chat:fileblob:" + conversationID + ":" + filename
	err = services.StoreFileBlobInRedis(redisKey, fileBytes)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to store file in Redis"})
		return
	}

	// Construct the file URL (assuming server runs at http://localhost:8081)
	fileURL := "/uploads/" + conversationID + "/" + filename

	// Determine message type
	ext := strings.ToLower(filepath.Ext(filename))
	var messageType models.MessageType
	switch ext {
	case ".png", ".jpg", ".jpeg":
		messageType = models.MessageTypeImage
	case ".wav", ".mp3":
		messageType = models.MessageTypeVoice
	default:
		messageType = models.MessageTypeFile
	}

	// Get sender_id from form (or query)
	senderID := c.PostForm("sender_id")
	if senderID == "" {
		senderID = c.Query("sender_id")
	}
	if senderID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "sender_id is required"})
		return
	}
	senderUUID, err := uuid.Parse(senderID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid sender_id"})
		return
	}
	convUUID, err := uuid.Parse(conversationID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation_id"})
		return
	}

	// Create message in DB and Redis
	message, err := h.chatService.SendMessage(convUUID, senderUUID, fileURL, messageType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"url": fileURL, "message": message})
}

// DownloadFileFromRedis handles downloading a file blob from Redis
func (h *ChatHandler) DownloadFileFromRedis(c *gin.Context) {
	conversationID := c.Param("conversation_id")
	filename := c.Param("filename")
	redisKey := "chat:fileblob:" + conversationID + ":" + filename

	data, err := services.GetFileBlobFromRedis(redisKey)
	if err != nil || data == nil {
		c.JSON(404, gin.H{"error": "File not found in Redis"})
		return
	}

	// Set appropriate headers for download
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Header("Content-Type", "application/octet-stream")
	c.Data(200, "application/octet-stream", data)
}
