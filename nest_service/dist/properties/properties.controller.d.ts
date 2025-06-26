import { PropertiesService } from './properties.service';
import { CreatePropertyDto, UpdatePropertyDto } from './dto/property.dto';
import { PropertyImage } from './entities/property-image.entity';
import { Property } from './entities/property.entity';
export declare class PropertiesController {
    private readonly propertiesService;
    constructor(propertiesService: PropertiesService);
    create(createPropertyDto: CreatePropertyDto): Promise<Property>;
    findAll(): Promise<{}>;
    findOne(id: string): Promise<Property>;
    update(id: string, updatePropertyDto: UpdatePropertyDto): Promise<Property>;
    remove(id: string): Promise<void>;
    uploadImages(propertyId: string, files: Express.Multer.File[], metadataJson?: string): Promise<PropertyImage[]>;
    uploadVideos(propertyId: string, files: Express.Multer.File[], metadataJson?: string): unknown;
}
