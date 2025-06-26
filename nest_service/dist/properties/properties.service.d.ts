import { Repository } from 'typeorm';
import { Property } from './entities/property.entity';
import { Company } from './entities/company.entity';
import { CreatePropertyDto, UpdatePropertyDto } from './dto/property.dto';
import { PropertyImage } from './entities/property-image.entity';
import { PropertyVideo } from './entities/property-video.entity';
import { PropertyLocation } from './entities/property-location.entity';
export declare class PropertiesService {
    private readonly propertyRepository;
    private readonly companyRepository;
    private readonly propertyImageRepository;
    private readonly propertyVideoRepository;
    private readonly locationRepository;
    constructor(propertyRepository: Repository<Property>, companyRepository: Repository<Company>, propertyImageRepository: Repository<PropertyImage>, propertyVideoRepository: Repository<PropertyVideo>, locationRepository: Repository<PropertyLocation>);
    create(createPropertyDto: CreatePropertyDto): Promise<Property>;
    findAll(): Promise<Property[]>;
    findOne(id: string): Promise<Property>;
    update(id: string, updatePropertyDto: UpdatePropertyDto): Promise<Property>;
    remove(id: string): Promise<void>;
    addImage(propertyId: string, imageUrl: string, body: {
        isPrimary?: string;
        caption?: string;
        order?: string;
        filePath?: string;
    }): Promise<PropertyImage>;
    addVideo(propertyId: string, videoUrl: string, body: {
        isPrimary?: string;
        caption?: string;
        order?: string;
    }): Promise<PropertyVideo>;
    addOrUpdateLocation(propertyId: string, locationDto: Partial<PropertyLocation>): Promise<PropertyLocation>;
}
