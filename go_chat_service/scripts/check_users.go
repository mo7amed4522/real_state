package main

import (
	"fmt"
	"log"
	"os"

	"go-chat-service/database"
	"go-chat-service/models"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	// Load environment variables
	os.Setenv("DB_HOST", "localhost")
	os.Setenv("DB_PORT", "5432")
	os.Setenv("DB_USER", "postgres")
	os.Setenv("DB_PASSWORD", "password")
	os.Setenv("DB_NAME", "chat_service")
	os.Setenv("DB_SSL_MODE", "disable")

	// Initialize database
	database.InitDB()

	// Check existing users
	fmt.Println("=== Existing Users ===")
	var users []models.User
	err := database.DB.Find(&users).Error
	if err != nil {
		log.Fatal("Failed to fetch users:", err)
	}

	if len(users) == 0 {
		fmt.Println("No users found in database")
	} else {
		for _, user := range users {
			fmt.Printf("ID: %s, Email: %s, Name: %s %s, Role: %s, Status: %s\n",
				user.ID, user.Email, user.FirstName, user.LastName, user.Role, user.Status)
		}
	}

	// Check specific user IDs from the error
	user1ID := "50b46bfd-de84-4289-bf64-4606cbcd204d"
	user2ID := "4146072f-d75a-4ec9-baf1-a4b86577f470"

	fmt.Printf("\n=== Checking Specific Users ===\n")
	
	// Check user1
	var user1 models.User
	err = database.DB.Where("id = ?", user1ID).First(&user1).Error
	if err != nil {
		fmt.Printf("User1 (%s) NOT FOUND: %v\n", user1ID, err)
	} else {
		fmt.Printf("User1 (%s) FOUND: %s %s (%s)\n", user1ID, user1.FirstName, user1.LastName, user1.Email)
	}

	// Check user2
	var user2 models.User
	err = database.DB.Where("id = ?", user2ID).First(&user2).Error
	if err != nil {
		fmt.Printf("User2 (%s) NOT FOUND: %v\n", user2ID, err)
	} else {
		fmt.Printf("User2 (%s) FOUND: %s %s (%s)\n", user2ID, user2.FirstName, user2.LastName, user2.Email)
	}

	// Create missing users if needed
	fmt.Printf("\n=== Creating Missing Users ===\n")
	
	// Create user1 if not exists
	if database.DB.Where("id = ?", user1ID).First(&user1).Error != nil {
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
		user1 = models.User{
			ID:           uuid.MustParse(user1ID),
			Email:        "user1@example.com",
			PasswordHash: string(hashedPassword),
			FirstName:    "John",
			LastName:     "Doe",
			CountryCode:  "+1",
			PhoneNumber:  "1234567890",
			Role:         models.UserRoleBuyer,
			Status:       models.UserStatusActive,
		}
		
		err = database.DB.Create(&user1).Error
		if err != nil {
			fmt.Printf("Failed to create user1: %v\n", err)
		} else {
			fmt.Printf("Created user1: %s %s (%s)\n", user1.FirstName, user1.LastName, user1.Email)
		}
	}

	// Create user2 if not exists
	if database.DB.Where("id = ?", user2ID).First(&user2).Error != nil {
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
		user2 = models.User{
			ID:           uuid.MustParse(user2ID),
			Email:        "user2@example.com",
			PasswordHash: string(hashedPassword),
			FirstName:    "Jane",
			LastName:     "Smith",
			CountryCode:  "+1",
			PhoneNumber:  "0987654321",
			Role:         models.UserRoleDeveloper,
			Status:       models.UserStatusActive,
		}
		
		err = database.DB.Create(&user2).Error
		if err != nil {
			fmt.Printf("Failed to create user2: %v\n", err)
		} else {
			fmt.Printf("Created user2: %s %s (%s)\n", user2.FirstName, user2.LastName, user2.Email)
		}
	}

	fmt.Printf("\n=== Users Ready for Conversation ===\n")
	fmt.Printf("User1: %s (%s)\n", user1ID, "user1@example.com")
	fmt.Printf("User2: %s (%s)\n", user2ID, "user2@example.com")
	fmt.Printf("\nYou can now create a conversation between these users!\n")
} 