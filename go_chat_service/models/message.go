package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type MessageType string

const (
	MessageTypeText  MessageType = "text"
	MessageTypeImage MessageType = "image"
	MessageTypeFile  MessageType = "file"
)

type Message struct {
	ID             uuid.UUID   `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	ConversationID uuid.UUID   `json:"conversationId" gorm:"type:uuid;not null"`
	SenderID       uuid.UUID   `json:"senderId" gorm:"type:uuid;not null"`
	Content        string      `json:"content" gorm:"not null"`
	MessageType    MessageType `json:"messageType" gorm:"type:varchar(20);default:'text'"`
	IsRead         bool        `json:"isRead" gorm:"default:false"`
	CreatedAt      time.Time   `json:"createdAt"`
	UpdatedAt      time.Time   `json:"updatedAt"`

	// Relations
	Conversation Conversation `json:"conversation" gorm:"foreignKey:ConversationID"`
	Sender       User         `json:"sender" gorm:"foreignKey:SenderID"`
}

func (m *Message) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}
