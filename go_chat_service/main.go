package main

import (
	"log"
	"os"

	"go-chat-service/database"
	"go-chat-service/handlers"
	"go-chat-service/routes"
	"go-chat-service/services"
	"go-chat-service/websocket"

	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load("config.env"); err != nil {
		log.Println("Warning: config.env file not found, using system environment variables")
	}

	// Initialize database
	database.InitDB()
	database.InitRedis()

	// Initialize services
	chatService := services.NewChatService()
	userService := services.NewUserService()

	// Initialize handlers
	chatHandler := handlers.NewChatHandler(chatService, userService)
	userHandler := handlers.NewUserHandler(userService)

	// Initialize WebSocket hub
	hub := websocket.NewHub(chatService)
	go hub.Run()

	// Setup routes
	router := routes.SetupRoutes(chatHandler, userHandler, hub)

	// Get port from environment
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8081"
	}

	log.Printf("Starting Go Chat Service on port %s", port)
	log.Fatal(router.Run(":" + port))
}
