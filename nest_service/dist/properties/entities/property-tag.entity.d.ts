import { Property } from './property.entity';
export declare class PropertyTag {
    id: string;
    propertyId: string;
    property: Property;
    tagName: string;
    relevanceScore: number;
}
