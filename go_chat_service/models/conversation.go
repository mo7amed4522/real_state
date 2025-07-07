package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Conversation struct {
	ID             uuid.UUID  `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Participant1ID uuid.UUID  `json:"participant1Id" gorm:"type:uuid;not null"`
	Participant2ID uuid.UUID  `json:"participant2Id" gorm:"type:uuid;not null"`
	LastMessageID  *uuid.UUID `json:"lastMessageId" gorm:"type:uuid"`
	CreatedAt      time.Time  `json:"createdAt"`
	UpdatedAt      time.Time  `json:"updatedAt"`

	// Relations
	Participant1 User      `json:"participant1" gorm:"foreignKey:Participant1ID"`
	Participant2 User      `json:"participant2" gorm:"foreignKey:Participant2ID"`
	LastMessage  *Message  `json:"lastMessage" gorm:"foreignKey:LastMessageID"`
	Messages     []Message `json:"messages" gorm:"foreignKey:ConversationID"`
}

func (c *Conversation) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return nil
}

func (c *Conversation) GetOtherParticipant(userID uuid.UUID) uuid.UUID {
	if c.Participant1ID == userID {
		return c.Participant2ID
	}
	return c.Participant1ID
}
