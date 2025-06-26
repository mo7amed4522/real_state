import { CompaniesService } from './companies.service';
import { CreateCompanyDto, UpdateCompanyDto } from './dto/company.dto';
export declare class CompaniesController {
    private readonly companiesService;
    constructor(companiesService: CompaniesService);
    create(createCompanyDto: CreateCompanyDto): Promise<import("../properties/entities/company.entity").Company>;
    findAll(): Promise<{}>;
    findOne(id: string): Promise<import("../properties/entities/company.entity").Company>;
    update(id: string, updateCompanyDto: UpdateCompanyDto): Promise<import("../properties/entities/company.entity").Company>;
    remove(id: string): Promise<void>;
    uploadLogo(companyId: string, file: Express.Multer.File): unknown;
}
