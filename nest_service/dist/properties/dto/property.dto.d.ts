import { PropertyType, PropertyStatus } from '../entities/property.entity';
export declare class CreatePropertyDto {
    title: string;
    description?: string;
    price: number;
    propertyType: PropertyType;
    status?: PropertyStatus;
    isFeatured?: boolean;
    companyId: string;
}
export declare class UpdatePropertyDto {
    title?: string;
    description?: string;
    price?: number;
    propertyType?: PropertyType;
    status?: PropertyStatus;
    isFeatured?: boolean;
}
