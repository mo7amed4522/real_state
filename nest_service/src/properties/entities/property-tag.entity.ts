import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Property } from './property.entity';

@Entity('property_tags')
export class PropertyTag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  propertyId: string;

  @ManyToOne(() => Property, (property) => property.tags)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column()
  tagName: string;

  @Column('float', { default: 1.0 })
  relevanceScore: number;
} 