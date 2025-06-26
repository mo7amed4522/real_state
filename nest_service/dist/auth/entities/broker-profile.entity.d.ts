import { User } from './user.entity';
import { SubscriptionType } from './developer-profile.entity';
export declare class BrokerProfile {
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
