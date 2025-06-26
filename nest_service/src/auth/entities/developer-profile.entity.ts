import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

export enum SubscriptionType {
  BASIC = 'basic',
  PREMIUM = 'premium'
}

@Entity('developer_profiles')
export class DeveloperProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @OneToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ nullable: true })
  companyName: string;

  @Column({ nullable: true })
  licenseNumber: string;

  @Column({ nullable: true })
  address: string;

  @Column({ nullable: true })
  contactEmail: string;

  @Column({ nullable: true })
  contactPhone: string;

  @Column({ default: true })
  isActive: boolean;

  @Column({
    type: 'enum',
    enum: SubscriptionType,
    default: SubscriptionType.BASIC
  })
  subscriptionType: SubscriptionType;

  @Column({ nullable: true })
  subscriptionExpiry: Date;

  @CreateDateColumn()
  createdAt: Date;
} 