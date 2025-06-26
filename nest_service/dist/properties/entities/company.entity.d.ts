import { Property } from './property.entity';
export declare class Company {
    id: string;
    name: string;
    website?: string;
    phone?: string;
    address?: string;
    logoUrl?: string;
    logoFileName?: string;
    properties: Property[];
    createdAt: Date;
    updatedAt: Date;
}
