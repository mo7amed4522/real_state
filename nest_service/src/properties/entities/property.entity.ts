import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany, ManyToOne, JoinColumn, OneToOne } from 'typeorm';
import { Company } from './company.entity';
import { PropertyImage } from './property-image.entity';
import { PropertyLocation } from './property-location.entity';
import { PropertyBuildingInfo } from './property-building-info.entity';
import { PropertyView } from './property-view.entity';
import { PropertyTag } from './property-tag.entity';

export enum PropertyType {
  APARTMENT = 'apartment',
  VILLA = 'villa',
  CONDO = 'condo',
  OFFICE = 'office',
  LAND = 'land',
}

export enum PropertyStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  SOLD = 'sold',
  UNDER_OFFER = 'under-offer',
}

@Entity('properties')
export class Property {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text', { nullable: true })
  description?: string;

  @Column('decimal', { precision: 12, scale: 2 })
  price: number;

  @Column({ type: 'enum', enum: PropertyType })
  propertyType: PropertyType;

  @Column({ type: 'enum', enum: PropertyStatus, default: PropertyStatus.DRAFT })
  status: PropertyStatus;

  @Column({ default: false })
  isFeatured: boolean;

  @Column()
  companyId: string;

  @ManyToOne(() => Company, (company) => company.properties)
  @JoinColumn({ name: 'companyId' })
  company: Company;

  @OneToMany(() => PropertyImage, (image) => image.property)
  images: PropertyImage[];

  @OneToOne(() => PropertyLocation, (location) => location.property)
  location: PropertyLocation;

  @OneToOne(() => PropertyBuildingInfo, (info) => info.property)
  buildingInfo: PropertyBuildingInfo;

  @OneToOne(() => PropertyView, (view) => view.property)
  view: PropertyView;

  @OneToMany(() => PropertyTag, (tag) => tag.property)
  tags: PropertyTag[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
} 