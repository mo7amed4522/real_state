import { Repository } from 'typeorm';
import { Company } from '../properties/entities/company.entity';
import { CreateCompanyDto } from './dto/company.dto';
import { UpdateCompanyDto } from './dto/company.dto';
export declare class CompaniesService {
    private readonly companyRepository;
    constructor(companyRepository: Repository<Company>);
    create(createCompanyDto: CreateCompanyDto): Promise<Company>;
    findAll(): Promise<Company[]>;
    findOne(id: string): Promise<Company>;
    update(id: string, updateCompanyDto: UpdateCompanyDto): Promise<Company>;
    remove(id: string): Promise<void>;
    updateLogo(id: string, logoUrl: string, logoFileName: string): Promise<Company>;
}
