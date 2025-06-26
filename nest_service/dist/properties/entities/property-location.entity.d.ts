import { Property } from './property.entity';
export declare class PropertyLocation {
    id: string;
    propertyId: string;
    property: Property;
    streetAddress?: string;
    city?: string;
    state?: string;
    postalCode?: string;
    country?: string;
    latitude?: number;
    longitude?: number;
    neighborhood?: string;
    nearbyAmenities?: object;
}
