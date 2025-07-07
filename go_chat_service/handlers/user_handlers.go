package handlers

import (
	"net/http"

	"go-chat-service/models"
	"go-chat-service/services"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type UserHandler struct {
	userService *services.UserService
}

func NewUserHandler(userService *services.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
	}
}

// GetAllUsers gets all users
func (h *UserHandler) GetAllUsers(c *gin.Context) {
	users, err := h.userService.GetAllUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
}

// GetUserByID gets a user by ID
func (h *UserHandler) GetUserByID(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	user, err := h.userService.GetUserByID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user": user,
	})
}

// GetUsersByRole gets users by role
func (h *UserHandler) GetUsersByRole(c *gin.Context) {
	role := c.Param("role")

	// Validate role
	validRoles := map[string]models.UserRole{
		"buyer":     models.UserRoleBuyer,
		"developer": models.UserRoleDeveloper,
		"broker":    models.UserRoleBroker,
		"admin":     models.UserRoleAdmin,
	}

	userRole, exists := validRoles[role]
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid role"})
		return
	}

	users, err := h.userService.GetUsersByRole(userRole)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
}

// GetActiveUsers gets all active users
func (h *UserHandler) GetActiveUsers(c *gin.Context) {
	users, err := h.userService.GetActiveUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
}

// CreateUser creates a new user (for testing purposes)
func (h *UserHandler) CreateUser(c *gin.Context) {
	var request struct {
		ID          string `json:"id"`
		Email       string `json:"email" binding:"required"`
		Password    string `json:"password" binding:"required"`
		FirstName   string `json:"firstName" binding:"required"`
		LastName    string `json:"lastName" binding:"required"`
		CountryCode string `json:"countryCode" binding:"required"`
		PhoneNumber string `json:"phoneNumber" binding:"required"`
		Role        string `json:"role"`
		Status      string `json:"status"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse user ID if provided, otherwise generate new one
	var userID uuid.UUID
	if request.ID != "" {
		var err error
		userID, err = uuid.Parse(request.ID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}
	} else {
		userID = uuid.New()
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(request.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Set default values
	role := models.UserRoleBuyer
	if request.Role != "" {
		role = models.UserRole(request.Role)
	}

	status := models.UserStatusActive
	if request.Status != "" {
		status = models.UserStatus(request.Status)
	}

	user := models.User{
		ID:           userID,
		Email:        request.Email,
		PasswordHash: string(hashedPassword),
		FirstName:    request.FirstName,
		LastName:     request.LastName,
		CountryCode:  request.CountryCode,
		PhoneNumber:  request.PhoneNumber,
		Role:         role,
		Status:       status,
	}

	err = h.userService.CreateUser(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"user": user,
	})
}
