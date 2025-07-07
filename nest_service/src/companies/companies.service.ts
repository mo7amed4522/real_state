import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Company } from '../properties/entities/company.entity';
import { CreateCompanyDto } from './dto/company.dto';
import { UpdateCompanyDto } from './dto/company.dto';
import { getFullLogoUrl } from './utils/file-upload.utils';
import { promises as fsPromises } from 'fs';
import { join } from 'path';

@Injectable()
export class CompaniesService {
  constructor(
    @InjectRepository(Company)
    private readonly companyRepository: Repository<Company>,
  ) {}

  async create(createCompanyDto: CreateCompanyDto): Promise<Company> {
    const company = this.companyRepository.create(createCompanyDto);
    return this.companyRepository.save(company);
  }

  async findAll(): Promise<Company[]> {
    return this.companyRepository.find();
  }

  async findOne(id: string): Promise<Company> {
    const company = await this.companyRepository.findOneBy({ id });
    if (!company) {
      throw new NotFoundException(`Company with ID "${id}" not found`);
    }
    return company;
  }

  async update(id: string, updateCompanyDto: UpdateCompanyDto): Promise<Company> {
    const company = await this.findOne(id);
    this.companyRepository.merge(company, updateCompanyDto);
    return this.companyRepository.save(company);
  }

  async remove(id: string): Promise<void> {
    const result = await this.companyRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Company with ID "${id}" not found`);
    }
  }

  async updateLogo(id: string, logoUrl: string, logoFileName: string): Promise<Company> {
    const company = await this.findOne(id);
    company.logoUrl = logoUrl;
    company.logoFileName = logoFileName;
    return this.companyRepository.save(company);
  }

  /**
   * Test method to verify logo URL generation for a company
   * @param companyId - The company ID to test
   * @returns Object containing test information and generated URL
   */
  async testLogoUrl(companyId: string) {
    const company = await this.findOne(companyId);
    
    if (!company.logoUrl) {
      throw new NotFoundException('Company has no logo uploaded');
    }

    // Generate the expected URL structure
    const expectedUrl = getFullLogoUrl(companyId, company.logoFileName);
    
    // Check if the file actually exists on disk
    const filePath = join(process.cwd(), 'uploads', 'companies', companyId, company.logoFileName);
    const fileExists = await fsPromises.access(filePath).then(() => true).catch(() => false);
    
    return {
      companyId: companyId,
      storedUrl: company.logoUrl,
      expectedUrl: expectedUrl,
      fileName: company.logoFileName,
      fileExists: fileExists,
      filePath: filePath,
      urlsMatch: company.logoUrl === expectedUrl,
      testResult: company.logoUrl === expectedUrl && fileExists ? 'PASS' : 'FAIL'
    };
  }
} 