import { DeveloperProfile } from './developer-profile.entity';
import { BrokerProfile } from './broker-profile.entity';
export declare enum UserRole {
    BUYER = "buyer",
    DEVELOPER = "developer",
    BROKER = "broker",
    ADMIN = "admin"
}
export declare enum UserStatus {
    ACTIVE = "active",
    BLOCKED = "blocked",
    PENDING_VERIFICATION = "pending_verification"
}
export declare class User {
    id: string;
    email: string;
    passwordHash: string;
    firstName: string;
    lastName: string;
    phone?: string;
    role: UserRole;
    status: UserStatus;
    avatarUrl?: string;
    avatarFileName?: string;
    company?: string;
    licenseNumber?: string;
    subscriptionExpiry?: Date;
    resetPasswordToken?: string;
    resetPasswordExpires?: Date;
    createdAt: Date;
    updatedAt: Date;
    developerProfile?: DeveloperProfile;
    brokerProfile?: BrokerProfile;
}
