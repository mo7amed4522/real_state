import { IsString, IsNotEmpty, IsNumber, IsEnum, IsBoolean, IsOptional, IsUUID } from 'class-validator';
import { PropertyType, PropertyStatus } from '../entities/property.entity';

export class CreatePropertyDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsNumber()
  price: number;

  @IsEnum(PropertyType)
  propertyType: PropertyType;

  @IsEnum(PropertyStatus)
  @IsOptional()
  status?: PropertyStatus;

  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @IsUUID()
  companyId: string;

  @IsNumber()
  @IsOptional()
  sellingPriceInclVat?: number;

  @IsNumber()
  @IsOptional()
  landRegistrationFee?: number;

  @IsNumber()
  @IsOptional()
  oqoodAmount?: number;

  @IsNumber()
  @IsOptional()
  applicableFeesToDubaiLandDepartment?: number;

  @IsString()
  @IsOptional()
  propertyUsage?: string;

  @IsNumber()
  @IsOptional()
  plotAreaSqFt?: number;

  @IsOptional()
  amenities?: string[];

  @IsOptional()
  paymentPlan?: { milestone: string; percent: number; aed: number }[];
}

export class UpdatePropertyDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsNumber()
  @IsOptional()
  price?: number;

  @IsEnum(PropertyType)
  @IsOptional()
  propertyType?: PropertyType;

  @IsEnum(PropertyStatus)
  @IsOptional()
  status?: PropertyStatus;

  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @IsNumber()
  @IsOptional()
  sellingPriceInclVat?: number;

  @IsNumber()
  @IsOptional()
  landRegistrationFee?: number;

  @IsNumber()
  @IsOptional()
  oqoodAmount?: number;

  @IsNumber()
  @IsOptional()
  applicableFeesToDubaiLandDepartment?: number;

  @IsString()
  @IsOptional()
  propertyUsage?: string;

  @IsNumber()
  @IsOptional()
  plotAreaSqFt?: number;

  @IsOptional()
  amenities?: string[];

  @IsOptional()
  paymentPlan?: { milestone: string; percent: number; aed: number }[];
} 