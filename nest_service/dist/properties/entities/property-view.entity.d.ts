import { Property } from './property.entity';
export declare class PropertyView {
    id: string;
    propertyId: string;
    property: Property;
    bestViewDescription?: string;
    virtualTourUrl?: string;
    droneVideoUrl?: string;
    panoramaImages?: object;
}
