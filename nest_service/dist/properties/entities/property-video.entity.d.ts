import { Property } from './property.entity';
export declare class PropertyVideo {
    id: string;
    propertyId: string;
    property: Property;
    videoUrl: string;
    isPrimary: boolean;
    caption?: string;
    order: number;
}
