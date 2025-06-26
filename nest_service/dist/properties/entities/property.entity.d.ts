import { Company } from './company.entity';
import { PropertyImage } from './property-image.entity';
import { PropertyLocation } from './property-location.entity';
import { PropertyBuildingInfo } from './property-building-info.entity';
import { PropertyView } from './property-view.entity';
import { PropertyTag } from './property-tag.entity';
export declare enum PropertyType {
    APARTMENT = "apartment",
    VILLA = "villa",
    CONDO = "condo",
    OFFICE = "office",
    LAND = "land"
}
export declare enum PropertyStatus {
    DRAFT = "draft",
    PUBLISHED = "published",
    SOLD = "sold",
    UNDER_OFFER = "under-offer"
}
export declare class Property {
    id: string;
    title: string;
    description?: string;
    price: number;
    propertyType: PropertyType;
    status: PropertyStatus;
    isFeatured: boolean;
    companyId: string;
    company: Company;
    images: PropertyImage[];
    location: PropertyLocation;
    buildingInfo: PropertyBuildingInfo;
    view: PropertyView;
    tags: PropertyTag[];
    createdAt: Date;
    updatedAt: Date;
}
