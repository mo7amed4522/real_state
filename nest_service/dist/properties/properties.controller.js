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
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PropertiesController = void 0;
const common_1 = require("@nestjs/common");
const properties_service_1 = require("./properties.service");
const property_dto_1 = require("./dto/property.dto");
const platform_express_1 = require("@nestjs/platform-express");
const multer_1 = require("multer");
const file_upload_utils_1 = require("./utils/file-upload.utils");
let PropertiesController = class PropertiesController {
    constructor(propertiesService) {
        this.propertiesService = propertiesService;
    }
    create(createPropertyDto) {
        return this.propertiesService.create(createPropertyDto);
    }
    findAll() {
        return this.propertiesService.findAll();
    }
    findOne(id) {
        return this.propertiesService.findOne(id);
    }
    update(id, updatePropertyDto) {
        return this.propertiesService.update(id, updatePropertyDto);
    }
    remove(id) {
        return this.propertiesService.remove(id);
    }
    async uploadImages(propertyId, files, metadataJson) {
        if (!files || files.length === 0) {
            throw new common_1.BadRequestException('No files uploaded');
        }
        let metadata = [];
        if (metadataJson) {
            try {
                metadata = JSON.parse(metadataJson);
            }
            catch {
                throw new common_1.BadRequestException('Invalid metadata JSON');
            }
        }
        const images = [];
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const imageUrl = (0, file_upload_utils_1.getPublicFileUrl)(propertyId, file.filename);
            const meta = metadata[i] || {};
            const filePath = file.path;
            const image = await this.propertiesService.addImage(propertyId, imageUrl, { ...meta, filePath });
            images.push(image);
        }
        return images;
    }
    async uploadVideos(propertyId, files, metadataJson) {
        if (!files || files.length === 0) {
            throw new common_1.BadRequestException('No files uploaded');
        }
        let metadata = [];
        if (metadataJson) {
            try {
                metadata = JSON.parse(metadataJson);
            }
            catch {
                throw new common_1.BadRequestException('Invalid metadata JSON');
            }
        }
        const videos = [];
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const videoUrl = (0, file_upload_utils_1.getPublicFileUrl)(propertyId, file.filename);
            const meta = metadata[i] || {};
            const video = await this.propertiesService.addVideo(propertyId, videoUrl, meta);
            videos.push(video);
        }
        return videos;
    }
};
exports.PropertiesController = PropertiesController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [property_dto_1.CreatePropertyDto]),
    __metadata("design:returntype", void 0)
], PropertiesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PropertiesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PropertiesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, property_dto_1.UpdatePropertyDto]),
    __metadata("design:returntype", void 0)
], PropertiesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PropertiesController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)(':id/images'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FilesInterceptor)('files', 10, {
        storage: (0, multer_1.diskStorage)({
            destination: (req, file, cb) => {
                const propertyId = req.params.id;
                const uploadDir = (0, file_upload_utils_1.ensurePropertyUploadDir)(propertyId);
                cb(null, uploadDir);
            },
            filename: (req, file, cb) => {
                cb(null, (0, file_upload_utils_1.generateEncryptedFileName)(file.originalname));
            },
        }),
        fileFilter: (req, file, cb) => {
            if (!file.mimetype.startsWith('image/')) {
                return cb(new common_1.BadRequestException('Only image files are allowed!'), false);
            }
            cb(null, true);
        },
        limits: { fileSize: 5 * 1024 * 1024 },
    })),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.UploadedFiles)()),
    __param(2, (0, common_1.Body)('metadata')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Array, String]),
    __metadata("design:returntype", typeof (_a = typeof Promise !== "undefined" && Promise) === "function" ? _a : Object)
], PropertiesController.prototype, "uploadImages", null);
__decorate([
    (0, common_1.Post)(':id/videos'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FilesInterceptor)('videos', 10, {
        storage: (0, multer_1.diskStorage)({
            destination: (req, file, cb) => {
                const propertyId = req.params.id;
                const uploadDir = (0, file_upload_utils_1.ensurePropertyUploadDir)(propertyId);
                cb(null, uploadDir);
            },
            filename: (req, file, cb) => {
                cb(null, (0, file_upload_utils_1.generateEncryptedFileName)(file.originalname));
            },
        }),
        fileFilter: (req, file, cb) => {
            if (!file.mimetype.startsWith('video/')) {
                return cb(new common_1.BadRequestException('Only video files are allowed!'), false);
            }
            cb(null, true);
        },
        limits: { fileSize: 100 * 1024 * 1024 },
    })),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.UploadedFiles)()),
    __param(2, (0, common_1.Body)('metadata')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Array, String]),
    __metadata("design:returntype", Promise)
], PropertiesController.prototype, "uploadVideos", null);
exports.PropertiesController = PropertiesController = __decorate([
    (0, common_1.Controller)('properties'),
    __metadata("design:paramtypes", [properties_service_1.PropertiesService])
], PropertiesController);
//# sourceMappingURL=properties.controller.js.map