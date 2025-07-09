package websocket

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"go-chat-service/database"
	"go-chat-service/models"
	"go-chat-service/services"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

type Client struct {
	ID     uuid.UUID
	UserID uuid.UUID
	Conn   *websocket.Conn
	Hub    *Hub
	Send   chan []byte
	mu     sync.Mutex
}

type Hub struct {
	clients     map[uuid.UUID]*Client
	broadcast   chan []byte
	register    chan *Client
	unregister  chan *Client
	mu          sync.RWMutex
	ChatService *services.ChatService
}

type Message struct {
	Type      string      `json:"type"`
	Data      interface{} `json:"data"`
	UserID    uuid.UUID   `json:"userId,omitempty"`
	Timestamp int64       `json:"timestamp"`
}

type ChatMessage struct {
	ID             uuid.UUID `json:"id"`
	ConversationID uuid.UUID `json:"conversationId"`
	SenderID       uuid.UUID `json:"senderId"`
	Content        string    `json:"content"`
	MessageType    string    `json:"messageType"`
	IsRead         bool      `json:"isRead"`
	CreatedAt      string    `json:"createdAt"`
	Sender         UserInfo  `json:"sender"`
}

type UserInfo struct {
	ID        uuid.UUID `json:"id"`
	FirstName string    `json:"firstName"`
	LastName  string    `json:"lastName"`
	AvatarUrl *string   `json:"avatarUrl"`
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for development
	},
}

func NewHub(chatService *services.ChatService) *Hub {
	return &Hub{
		clients:     make(map[uuid.UUID]*Client),
		broadcast:   make(chan []byte),
		register:    make(chan *Client),
		unregister:  make(chan *Client),
		ChatService: chatService,
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.UserID] = client
			h.mu.Unlock()

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.UserID]; ok {
				delete(h.clients, client.UserID)
				close(client.Send)
			}
			h.mu.Unlock()

		case message := <-h.broadcast:
			h.mu.RLock()
			for _, client := range h.clients {
				select {
				case client.Send <- message:
				default:
					close(client.Send)
					delete(h.clients, client.UserID)
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (c *Client) readPump() {
	defer func() {
		c.Hub.unregister <- c
		c.Conn.Close()
	}()

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}

		// Handle incoming message
		var msg Message
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Printf("error unmarshaling message: %v", err)
			continue
		}

		// Process message based on type
		switch msg.Type {
		case "chat_message":
			// Parse the incoming data
			var chatMsg ChatMessage
			dataBytes, _ := json.Marshal(msg.Data)
			if err := json.Unmarshal(dataBytes, &chatMsg); err != nil {
				log.Printf("error unmarshaling chat message: %v", err)
				continue
			}

			// Save to PostgreSQL
			savedMsg, err := c.Hub.ChatService.SendMessage(
				chatMsg.ConversationID,
				chatMsg.SenderID,
				chatMsg.Content,
				models.MessageType(chatMsg.MessageType),
			)
			if err != nil {
				log.Printf("error saving chat message to DB: %v", err)
				continue
			}

			// Save to Redis (as JSON in a list per conversation)
			redisKey := "chat:messages:" + savedMsg.ConversationID.String()
			msgJson, _ := json.Marshal(savedMsg)
			err = database.RedisClient.RPush(context.Background(), redisKey, msgJson).Err()
			if err != nil {
				log.Printf("error saving chat message to Redis: %v", err)
			}

			// Prepare the message to broadcast (with DB fields)
			outMsg := Message{
				Type:      "chat_message",
				Data:      savedMsg,
				UserID:    chatMsg.SenderID,
				Timestamp: time.Now().Unix(),
			}
			outBytes, _ := json.Marshal(outMsg)
			c.Hub.broadcast <- outBytes
		case "typing":
			c.Hub.broadcast <- message
		}
	}
}

func (c *Client) writePump() {
	defer func() {
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.Send:
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			c.mu.Lock()
			err := c.Conn.WriteMessage(websocket.TextMessage, message)
			c.mu.Unlock()
			if err != nil {
				return
			}
		}
	}
}

func ServeWs(hub *Hub, w http.ResponseWriter, r *http.Request) {
	// Get user ID from query parameter
	userIDStr := r.URL.Query().Get("user_id")
	if userIDStr == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		http.Error(w, "invalid user_id", http.StatusBadRequest)
		return
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	client := &Client{
		ID:     uuid.New(),
		UserID: userID,
		Hub:    hub,
		Conn:   conn,
		Send:   make(chan []byte, 256),
	}

	client.Hub.register <- client

	go client.writePump()
	go client.readPump()
}
