import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn } from 'typeorm';
import { Property } from './property.entity';

@Entity('property_locations')
export class PropertyLocation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  propertyId: string;

  @OneToOne(() => Property, (property) => property.location)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column({ nullable: true })
  streetAddress?: string;

  @Column({ nullable: true })
  city?: string;

  @Column({ nullable: true })
  state?: string;

  @Column({ nullable: true })
  postalCode?: string;

  @Column({ nullable: true })
  country?: string;

  @Column('numeric', { precision: 9, scale: 6, nullable: true })
  latitude?: number;

  @Column('numeric', { precision: 9, scale: 6, nullable: true })
  longitude?: number;

  @Column({ nullable: true })
  neighborhood?: string;

  @Column('json', { nullable: true })
  nearbyAmenities?: object;
} 