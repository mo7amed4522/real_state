package database

import (
	"fmt"
	"log"
	"os"

	"go-chat-service/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func InitDB() {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_SSL_MODE"),
	)

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})

	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	log.Println("Database connected successfully")

	// Disable foreign key checks temporarily
	DB.Exec("SET session_replication_role = replica;")

	// Create tables manually in the correct order
	err = DB.AutoMigrate(&models.User{})
	if err != nil {
		log.Fatal("Failed to migrate users table:", err)
	}

	// Create conversations table
	err = DB.Exec(`
		CREATE TABLE IF NOT EXISTS conversations (
			id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
			participant1_id UUID NOT NULL,
			participant2_id UUID NOT NULL,
			last_message_id UUID,
			created_at TIMESTAMPTZ DEFAULT NOW(),
			updated_at TIMESTAMPTZ DEFAULT NOW(),
			CONSTRAINT fk_conversations_participant1 FOREIGN KEY (participant1_id) REFERENCES users(id),
			CONSTRAINT fk_conversations_participant2 FOREIGN KEY (participant2_id) REFERENCES users(id)
		)
	`).Error
	if err != nil {
		log.Fatal("Failed to create conversations table:", err)
	}

	// Create messages table
	err = DB.Exec(`
		CREATE TABLE IF NOT EXISTS messages (
			id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
			conversation_id UUID NOT NULL,
			sender_id UUID NOT NULL,
			content TEXT NOT NULL,
			message_type VARCHAR(20) DEFAULT 'text',
			is_read BOOLEAN DEFAULT false,
			created_at TIMESTAMPTZ DEFAULT NOW(),
			updated_at TIMESTAMPTZ DEFAULT NOW(),
			CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id),
			CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id)
		)
	`).Error
	if err != nil {
		log.Fatal("Failed to create messages table:", err)
	}

	// Re-enable foreign key checks
	DB.Exec("SET session_replication_role = DEFAULT;")

	log.Println("Database migrated successfully")
}
