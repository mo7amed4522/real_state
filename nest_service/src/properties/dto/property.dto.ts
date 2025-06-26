import { IsString, IsNotEmpty, IsNumber, IsEnum, IsBoolean, IsOptional, IsUUID } from 'class-validator';
import { PropertyType, PropertyStatus } from '../entities/property.entity';

export class CreatePropertyDto {
  @IsString()
  @IsNotEmpty()
  title: string;

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
}

export class UpdatePropertyDto {
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
} 