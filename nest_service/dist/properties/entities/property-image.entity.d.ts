import { Property } from './property.entity';
export declare class PropertyImage {
    id: string;
    propertyId: string;
    property: Property;
    imageUrl: string;
    isPrimary: boolean;
    caption?: string;
    order: number;
    tags?: string[];
}
