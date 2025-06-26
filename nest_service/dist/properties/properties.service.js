"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var _a, _b, _c, _d, _e;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PropertiesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const property_entity_1 = require("./entities/property.entity");
const company_entity_1 = require("./entities/company.entity");
const property_image_entity_1 = require("./entities/property-image.entity");
const property_video_entity_1 = require("./entities/property-video.entity");
const image_ai_utils_1 = require("./utils/image-ai.utils");
const location_ai_utils_1 = require("./utils/location-ai.utils");
const property_location_entity_1 = require("./entities/property-location.entity");
let PropertiesService = class PropertiesService {
    constructor(propertyRepository, companyRepository, propertyImageRepository, propertyVideoRepository, locationRepository) {
        this.propertyRepository = propertyRepository;
        this.companyRepository = companyRepository;
        this.propertyImageRepository = propertyImageRepository;
        this.propertyVideoRepository = propertyVideoRepository;
        this.locationRepository = locationRepository;
    }
    async create(createPropertyDto) {
        const company = await this.companyRepository.findOneBy({ id: createPropertyDto.companyId });
        if (!company) {
            throw new common_1.NotFoundException(`Company with ID "${createPropertyDto.companyId}" not found`);
        }
        const property = this.propertyRepository.create({
            ...createPropertyDto,
            company,
        });
        return this.propertyRepository.save(property);
    }
    async findAll() {
        return this.propertyRepository.find({ relations: ['company'] });
    }
    async findOne(id) {
        const property = await this.propertyRepository.findOne({ where: { id }, relations: ['company', 'images', 'location', 'buildingInfo', 'view', 'tags'] });
        if (!property) {
            throw new common_1.NotFoundException(`Property with ID "${id}" not found`);
        }
        return property;
    }
    async update(id, updatePropertyDto) {
        const property = await this.findOne(id);
        this.propertyRepository.merge(property, updatePropertyDto);
        return this.propertyRepository.save(property);
    }
    async remove(id) {
        const result = await this.propertyRepository.delete(id);
        if (result.affected === 0) {
            throw new common_1.NotFoundException(`Property with ID "${id}" not found`);
        }
    }
    async addImage(propertyId, imageUrl, body) {
        const property = await this.propertyRepository.findOneBy({ id: propertyId });
        if (!property) {
            throw new common_1.NotFoundException(`Property with ID "${propertyId}" not found`);
        }
        let tags = [];
        if (body.filePath) {
            tags = await (0, image_ai_utils_1.detectImageTags)(body.filePath);
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
    async addVideo(propertyId, videoUrl, body) {
        const property = await this.propertyRepository.findOneBy({ id: propertyId });
        if (!property) {
            throw new common_1.NotFoundException(`Property with ID "${propertyId}" not found`);
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
    async addOrUpdateLocation(propertyId, locationDto) {
        let location = await this.locationRepository.findOneBy({ propertyId });
        if (!location) {
            location = this.locationRepository.create({ propertyId, ...locationDto });
        }
        else {
            Object.assign(location, locationDto);
        }
        if (location.latitude && location.longitude) {
            location.nearbyAmenities = await (0, location_ai_utils_1.fetchNearbyAmenities)(Number(location.latitude), Number(location.longitude));
        }
        return this.locationRepository.save(location);
    }
};
exports.PropertiesService = PropertiesService;
exports.PropertiesService = PropertiesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(property_entity_1.Property)),
    __param(1, (0, typeorm_1.InjectRepository)(company_entity_1.Company)),
    __param(2, (0, typeorm_1.InjectRepository)(property_image_entity_1.PropertyImage)),
    __param(3, (0, typeorm_1.InjectRepository)(property_video_entity_1.PropertyVideo)),
    __param(4, (0, typeorm_1.InjectRepository)(property_location_entity_1.PropertyLocation)),
    __metadata("design:paramtypes", [typeof (_a = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _a : Object, typeof (_b = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _b : Object, typeof (_c = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _c : Object, typeof (_d = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _d : Object, typeof (_e = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _e : Object])
], PropertiesService);
//# sourceMappingURL=properties.service.js.map