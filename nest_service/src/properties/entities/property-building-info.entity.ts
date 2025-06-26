import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn } from 'typeorm';
import { Property } from './property.entity';

export enum ConstructionStatus {
  READY_TO_MOVE = 'ready_to_move',
  UNDER_CONSTRUCTION = 'under_construction',
}

@Entity('property_building_infos')
export class PropertyBuildingInfo {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  propertyId: string;

  @OneToOne(() => Property, (property) => property.buildingInfo)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column({ type: 'int', nullable: true })
  yearBuilt?: number;

  @Column({ type: 'int', nullable: true })
  squareFeet?: number;

  @Column({ type: 'int', nullable: true })
  bedrooms?: number;

  @Column({ type: 'int', nullable: true })
  bathrooms?: number;

  @Column({ type: 'int', nullable: true })
  floors?: number;

  @Column({ type: 'int', nullable: true })
  parkingSpots?: number;

  @Column('json', { nullable: true })
  amenities?: object;

  @Column({
    type: 'enum',
    enum: ConstructionStatus,
    default: ConstructionStatus.READY_TO_MOVE,
  })
  constructionStatus: ConstructionStatus;
} 