import { Property } from './property.entity';
export declare enum ConstructionStatus {
    READY_TO_MOVE = "ready_to_move",
    UNDER_CONSTRUCTION = "under_construction"
}
export declare class PropertyBuildingInfo {
    id: string;
    propertyId: string;
    property: Property;
    yearBuilt?: number;
    squareFeet?: number;
    bedrooms?: number;
    bathrooms?: number;
    floors?: number;
    parkingSpots?: number;
    amenities?: object;
    constructionStatus: ConstructionStatus;
}
