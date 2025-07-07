package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserRole string
type UserStatus string

const (
	UserRoleBuyer     UserRole = "buyer"
	UserRoleDeveloper UserRole = "developer"
	UserRoleBroker    UserRole = "broker"
	UserRoleAdmin     UserRole = "admin"

	UserStatusActive              UserStatus = "active"
	UserStatusBlocked             UserStatus = "blocked"
	UserStatusPendingVerification UserStatus = "pending_verification"
)

type User struct {
	ID                     uuid.UUID  `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Email                  string     `json:"email" gorm:"uniqueIndex;not null"`
	PasswordHash           string     `json:"-" gorm:"column:passwordHash;not null"`
	FirstName              string     `json:"firstName" gorm:"column:firstName;not null"`
	LastName               string     `json:"lastName" gorm:"column:lastName;not null"`
	CountryCode            string     `json:"countryCode" gorm:"column:countryCode;not null"`
	PhoneNumber            string     `json:"phoneNumber" gorm:"column:phoneNumber;uniqueIndex;not null"`
	Role                   UserRole   `json:"role" gorm:"type:varchar(20);default:'buyer'"`
	Status                 UserStatus `json:"status" gorm:"type:varchar(30);default:'pending_verification'"`
	AvatarUrl              *string    `json:"avatarUrl" gorm:"column:avatarUrl"`
	AvatarFileName         *string    `json:"avatarFileName" gorm:"column:avatarFileName"`
	Company                *string    `json:"company" gorm:"column:company"`
	LicenseNumber          *string    `json:"licenseNumber" gorm:"column:licenseNumber"`
	SubscriptionExpiry     *time.Time `json:"subscriptionExpiry" gorm:"column:subscriptionExpiry"`
	ResetPasswordToken     *string    `json:"-" gorm:"column:resetPasswordToken"`
	ResetPasswordExpires   *time.Time `json:"-" gorm:"column:resetPasswordExpires"`
	EmailVerificationToken *string    `json:"-" gorm:"column:emailVerificationToken"`
	CreatedAt              time.Time  `json:"createdAt" gorm:"column:createdAt"`
	UpdatedAt              time.Time  `json:"updatedAt" gorm:"column:updatedAt"`

	// Relations
	ConversationsAsParticipant1 []Conversation `json:"-" gorm:"foreignKey:Participant1ID"`
	ConversationsAsParticipant2 []Conversation `json:"-" gorm:"foreignKey:Participant2ID"`
	Messages                    []Message      `json:"-" gorm:"foreignKey:SenderID"`
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

func (u *User) GetFullName() string {
	return u.FirstName + " " + u.LastName
}
