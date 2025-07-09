package routes

import (
	"go-chat-service/handlers"
	"go-chat-service/websocket"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(chatHandler *handlers.ChatHandler, userHandler *handlers.UserHandler, hub *websocket.Hub) *gin.Engine {
	router := gin.Default()

	// CORS middleware
	router.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Chat routes
		chat := v1.Group("/chat")
		{
			chat.GET("/users/:user_id/conversations", chatHandler.GetUserConversations)
			chat.GET("/conversations/:conversation_id/messages", chatHandler.GetConversationMessages)
			chat.POST("/conversations", chatHandler.CreateConversation)
			chat.POST("/messages", chatHandler.SendMessage)
			chat.PUT("/conversations/:conversation_id/read", chatHandler.MarkConversationAsRead)
			chat.GET("/users/:user_id/unread-count", chatHandler.GetUnreadMessageCount)
			chat.POST("/conversations/:conversation_id/upload", chatHandler.UploadFile)
			chat.GET("/conversations/:conversation_id/files/:filename", chatHandler.DownloadFileFromRedis)
		}

		// User routes
		users := v1.Group("/users")
		{
			users.GET("/", userHandler.GetAllUsers)
			users.GET("/active", userHandler.GetActiveUsers)
			users.GET("/:user_id", userHandler.GetUserByID)
			users.GET("/role/:role", userHandler.GetUsersByRole)
			users.POST("/", userHandler.CreateUser) // Add user creation endpoint
		}
	}

	// WebSocket endpoint
	router.GET("/ws", func(c *gin.Context) {
		websocket.ServeWs(hub, c.Writer, c.Request)
	})

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"service": "go-chat-service",
		})
	})

	return router
}
