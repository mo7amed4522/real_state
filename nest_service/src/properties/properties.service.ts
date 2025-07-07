import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Property } from './entities/property.entity';
import { Company } from './entities/company.entity';
import { CreatePropertyDto, UpdatePropertyDto } from './dto/property.dto';
import { PropertyImage } from './entities/property-image.entity';
import { PropertyVideo } from './entities/property-video.entity';
import { detectImageTags } from './utils/image-ai.utils';
import { fetchNearbyAmenities } from './utils/location-ai.utils';
import { PropertyLocation } from './entities/property-location.entity';

@Injectable()
export class PropertiesService {
  constructor(
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
    @InjectRepository(Company)
    private readonly companyRepository: Repository<Company>,
    @InjectRepository(PropertyImage)
    private readonly propertyImageRepository: Repository<PropertyImage>,
    @InjectRepository(PropertyVideo)
    private readonly propertyVideoRepository: Repository<PropertyVideo>,
    @InjectRepository(PropertyLocation)
    private readonly locationRepository: Repository<PropertyLocation>,
  ) {}

  async create(createPropertyDto: CreatePropertyDto): Promise<Property> {
    const company = await this.companyRepository.findOneBy({ id: createPropertyDto.companyId });
    if (!company) {
      throw new NotFoundException(`Company with ID "${createPropertyDto.companyId}" not found`);
    }

    const property = this.propertyRepository.create({
      ...createPropertyDto,
      company,
    });

    return this.propertyRepository.save(property);
  }

  async findAll(): Promise<Property[]> {
    return this.propertyRepository.find({ relations: ['company'] });
  }

  async findOne(id: string): Promise<Property> {
    const property = await this.propertyRepository.findOne({ where: { id }, relations: ['company', 'images', 'location', 'buildingInfo', 'view', 'tags'] });
    if (!property) {
      throw new NotFoundException(`Property with ID "${id}" not found`);
    }
    return property;
  }

  async update(id: string, updatePropertyDto: UpdatePropertyDto): Promise<Property> {
    const property = await this.findOne(id);
    this.propertyRepository.merge(property, updatePropertyDto);
    return this.propertyRepository.save(property);
  }

  async remove(id: string): Promise<void> {
    const result = await this.propertyRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Property with ID "${id}" not found`);
    }
  }

  async addImage(propertyId: string, imageUrl: string, body: { isPrimary?: string; caption?: string; order?: string, filePath?: string }): Promise<PropertyImage> {
    // Validate property exists
    const property = await this.propertyRepository.findOneBy({ id: propertyId });
    if (!property) {
      throw new NotFoundException(`Property with ID "${propertyId}" not found`);
    }
    let tags: string[] = [];
    if (body.filePath) {
      tags = await detectImageTags(body.filePath);
    }
    const image = this.propertyImageRepository.create({
      propertyId,
      imageUrl,
      isPrimary: body.isPrimary === 'true',
      caption: body.caption,
      order: body.order ? parseInt(body.order, 10) : 0,
      tags,
    });
    return this.propertyImageRepository.save(image);
  }

  async addVideo(propertyId: string, videoUrl: string, body: { isPrimary?: string; caption?: string; order?: string }): Promise<PropertyVideo> {
    // Validate property exists
    const property = await this.propertyRepository.findOneBy({ id: propertyId });
    if (!property) {
      throw new NotFoundException(`Property with ID "${propertyId}" not found`);
    }
    const video = this.propertyVideoRepository.create({
      propertyId,
      videoUrl,
      isPrimary: body.isPrimary === 'true',
      caption: body.caption,
      order: body.order ? parseInt(body.order, 10) : 0,
    });
    return this.propertyVideoRepository.save(video);
  }

  async addOrUpdateLocation(propertyId: string, locationDto: Partial<PropertyLocation>): Promise<PropertyLocation> {
    // Save or update location
    let location = await this.locationRepository.findOneBy({ propertyId });
    if (!location) {
      location = this.locationRepository.create({ propertyId, ...locationDto });
    } else {
      Object.assign(location, locationDto);
    }
    // If lat/lng present, fetch amenities
    if (location.latitude && location.longitude) {
      location.nearbyAmenities = await fetchNearbyAmenities(Number(location.latitude), Number(location.longitude));
    }
    return this.locationRepository.save(location);
  }

  async findAllByCompany(companyId: string): Promise<Property[]> {
    return this.propertyRepository.find({
      where: { companyId },
      relations: ['company', 'images', 'location', 'buildingInfo', 'view', 'tags'],
    });
  }
} 