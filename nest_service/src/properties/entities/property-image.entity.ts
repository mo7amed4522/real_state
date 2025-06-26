import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Property } from './property.entity';

@Entity('property_images')
export class PropertyImage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  propertyId: string;

  @ManyToOne(() => Property, (property) => property.images)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column('text')
  imageUrl: string;

  @Column({ default: false })
  isPrimary: boolean;

  @Column({ nullable: true })
  caption?: string;

  @Column({ type: 'int', default: 0 })
  order: number;

  @Column('json', { nullable: true })
  tags?: string[];
} 