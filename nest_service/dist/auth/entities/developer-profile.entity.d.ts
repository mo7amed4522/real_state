import { User } from './user.entity';
export declare enum SubscriptionType {
    BASIC = "basic",
    PREMIUM = "premium"
}
export declare class DeveloperProfile {
    id: string;
    userId: string;
    user: User;
    companyName: string;
    licenseNumber: string;
    address: string;
    contactEmail: string;
    contactPhone: string;
    isActive: boolean;
    subscriptionType: SubscriptionType;
    subscriptionExpiry: Date;
    createdAt: Date;
}
