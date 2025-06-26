import { Controller, Get, Post, Body, Param, Put, Delete, HttpCode, HttpStatus, UseInterceptors, UploadedFile, BadRequestException, UploadedFiles } from '@nestjs/common';
import { PropertiesService } from './properties.service';
import { CreatePropertyDto, UpdatePropertyDto } from './dto/property.dto';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { ensurePropertyUploadDir, generateEncryptedFileName, getPublicFileUrl } from './utils/file-upload.utils';
import { PropertyImage } from './entities/property-image.entity';
import * as path from 'path';
import { Request } from 'express';
import { Property } from './entities/property.entity';

@Controller('properties')
export class PropertiesController {
  constructor(private readonly propertiesService: PropertiesService) {}

  @Post()
  create(@Body() createPropertyDto: CreatePropertyDto) {
    return this.propertiesService.create(createPropertyDto);
  }

  @Get()
  findAll() {
    return this.propertiesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.propertiesService.findOne(id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updatePropertyDto: UpdatePropertyDto) {
    return this.propertiesService.update(id, updatePropertyDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.propertiesService.remove(id);
  }

  @Post(':id/images')
  @UseInterceptors(FilesInterceptor('files', 10, {
    storage: diskStorage({
      destination: (req, file, cb) => {
        const propertyId = req.params.id;
        const uploadDir = ensurePropertyUploadDir(propertyId);
        cb(null, uploadDir);
      },
      filename: (req, file, cb) => {
        cb(null, generateEncryptedFileName(file.originalname));
      },
    }),
    fileFilter: (req, file, cb) => {
      if (!file.mimetype.startsWith('image/')) {
        return cb(new BadRequestException('Only image files are allowed!'), false);
      }
      cb(null, true);
    },
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB per file
  }))
  async uploadImages(
    @Param('id') propertyId: string,
    @UploadedFiles() files: Express.Multer.File[],
    @Body('metadata') metadataJson?: string
  ): Promise<PropertyImage[]> {
    if (!files || files.length === 0) {
      throw new BadRequestException('No files uploaded');
    }
    let metadata: any[] = [];
    if (metadataJson) {
      try {
        metadata = JSON.parse(metadataJson);
      } catch {
        throw new BadRequestException('Invalid metadata JSON');
      }
    }
    const images: PropertyImage[] = [];
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const imageUrl = getPublicFileUrl(propertyId, file.filename);
      const meta = metadata[i] || {};
      const filePath = file.path;
      const image = await this.propertiesService.addImage(propertyId, imageUrl, { ...meta, filePath });
      images.push(image);
    }
    return images;
  }

  @Post(':id/videos')
  @UseInterceptors(FilesInterceptor('videos', 10, {
    storage: diskStorage({
      destination: (req, file, cb) => {
        const propertyId = req.params.id;
        const uploadDir = ensurePropertyUploadDir(propertyId);
        cb(null, uploadDir);
      },
      filename: (req, file, cb) => {
        cb(null, generateEncryptedFileName(file.originalname));
      },
    }),
    fileFilter: (req, file, cb) => {
      if (!file.mimetype.startsWith('video/')) {
        return cb(new BadRequestException('Only video files are allowed!'), false);
      }
      cb(null, true);
    },
    limits: { fileSize: 100 * 1024 * 1024 }, // 100MB per file
  }))
  async uploadVideos(
    @Param('id') propertyId: string,
    @UploadedFiles() files: Express.Multer.File[],
    @Body('metadata') metadataJson?: string
  ) {
    if (!files || files.length === 0) {
      throw new BadRequestException('No files uploaded');
    }
    let metadata: any[] = [];
    if (metadataJson) {
      try {
        metadata = JSON.parse(metadataJson);
      } catch {
        throw new BadRequestException('Invalid metadata JSON');
      }
    }
    const videos = [];
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const videoUrl = getPublicFileUrl(propertyId, file.filename);
      const meta = metadata[i] || {};
      const video = await this.propertiesService.addVideo(propertyId, videoUrl, meta);
      videos.push(video);
    }
    return videos;
  }
} 