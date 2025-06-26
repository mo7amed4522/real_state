import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Property } from './property.entity';

@Entity('property_videos')
export class PropertyVideo {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  propertyId: string;

  @ManyToOne(() => Property, (property) => property.id)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column('text')
  videoUrl: string;

  @Column({ default: false })
  isPrimary: boolean;

  @Column({ nullable: true })
  caption?: string;

  @Column({ type: 'int', default: 0 })
  order: number;
} 