import { Controller, Post, Body, Get, Param, Put, Delete, HttpCode, HttpStatus, UseInterceptors, UploadedFile, BadRequestException, Res } from '@nestjs/common';
import { CompaniesService } from './companies.service';
import { CreateCompanyDto, UpdateCompanyDto } from './dto/company.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { ensureCompanyUploadDir, generateEncryptedFileName, getPublicFileUrl, getFullLogoUrl, getLegacyLogoUrl } from './utils/file-upload.utils';
import { createReadStream, existsSync } from 'fs';
import { join } from 'path';
import { Response } from 'express';

@Controller('companies')
export class CompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post()
  create(@Body() createCompanyDto: CreateCompanyDto) {
    return this.companiesService.create(createCompanyDto);
  }

  @Get()
  findAll() {
    return this.companiesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.companiesService.findOne(id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateCompanyDto: UpdateCompanyDto) {
    return this.companiesService.update(id, updateCompanyDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.companiesService.remove(id);
  }

  @Post(':id/logo')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: (req, file, cb) => {
        const companyId = req.params.id;
        const uploadDir = ensureCompanyUploadDir(companyId);
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
  }))
  async uploadLogo(
    @Param('id') companyId: string,
    @UploadedFile() file: Express.Multer.File
  ) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    
    // Generate full URL for the logo
    const logoUrl = getFullLogoUrl(companyId, file.filename);
    
    // Update company with full URL
    const updatedCompany = await this.companiesService.updateLogo(companyId, logoUrl, file.filename);
    
    return {
      company: updatedCompany,
      logoUrl: logoUrl,
      fileName: file.filename,
      message: 'Logo uploaded successfully'
    };
  }

  @Get('logo/:companyId/:filename')
  async getCompanyLogo(
    @Param('companyId') companyId: string,
    @Param('filename') filename: string,
    @Res() res: Response,
  ) {
    const filePath = join(process.cwd(), 'uploads', 'companies', companyId, filename);
    console.log('Looking for company logo:', filePath, 'Exists:', existsSync(filePath));
    
    if (!existsSync(filePath)) {
      return res.status(404).json({ message: 'Logo file not found' });
    }
    
    const stream = createReadStream(filePath);
    stream.pipe(res);
  }

  @Get(':id/logo-url')
  async getLogoUrl(@Param('id') companyId: string) {
    const company = await this.companiesService.findOne(companyId);
    
    if (!company.logoUrl) {
      throw new BadRequestException('Company has no logo uploaded');
    }
    
    return {
      companyId: companyId,
      logoUrl: company.logoUrl,
      fileName: company.logoFileName,
      message: 'Logo URL retrieved successfully'
    };
  }

  @Get(':id/test-logo-url')
  async testLogoUrl(@Param('id') companyId: string) {
    return this.companiesService.testLogoUrl(companyId);
  }
} 