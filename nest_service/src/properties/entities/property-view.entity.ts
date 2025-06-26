import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn } from 'typeorm';
import { Property } from './property.entity';

@Entity('property_views')
export class PropertyView {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  propertyId: string;

  @OneToOne(() => Property, (property) => property.view)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column('text', { nullable: true })
  bestViewDescription?: string;

  @Column('text', { nullable: true })
  virtualTourUrl?: string;

  @Column('text', { nullable: true })
  droneVideoUrl?: string;

  @Column('json', { nullable: true })
  panoramaImages?: object;
} 