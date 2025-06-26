import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';
import { SubscriptionType } from './developer-profile.entity';

@Entity('broker_profiles')
export class BrokerProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @OneToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  companyName: string;

  @Column()
  licenseNumber: string;

  @Column()
  address: string;

  @Column()
  contactEmail: string;

  @Column()
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