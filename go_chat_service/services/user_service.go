package services

import (
	"go-chat-service/database"
	"go-chat-service/models"

	"github.com/google/uuid"
)

type UserService struct{}

func NewUserService() *UserService {
	return &UserService{}
}

// GetAllUsers gets all users from the database
func (s *UserService) GetAllUsers() ([]models.User, error) {
	var users []models.User
	err := database.DB.Find(&users).Error
	return users, err
}

// GetUserByID gets a user by ID
func (s *UserService) GetUserByID(userID uuid.UUID) (*models.User, error) {
	var user models.User
	err := database.DB.Where("id = ?", userID).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// GetUsersByRole gets users by role
func (s *UserService) GetUsersByRole(role models.UserRole) ([]models.User, error) {
	var users []models.User
	err := database.DB.Where("role = ?", role).Find(&users).Error
	return users, err
}

// GetActiveUsers gets all active users
func (s *UserService) GetActiveUsers() ([]models.User, error) {
	var users []models.User
	err := database.DB.Where("status = ?", models.UserStatusActive).Find(&users).Error
	return users, err
}

// CreateUser creates a new user
func (s *UserService) CreateUser(user *models.User) error {
	return database.DB.Create(user).Error
}
