import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToOne, Index } from 'typeorm';
import { Exclude } from 'class-transformer';
import { DeveloperProfile } from './developer-profile.entity';
import { BrokerProfile } from './broker-profile.entity';

export enum UserRole {
  BUYER = 'buyer',
  DEVELOPER = 'developer',
  BROKER = 'broker',
  ADMIN = 'admin'
}

export enum UserStatus {
  ACTIVE = 'active',
  BLOCKED = 'blocked',
  PENDING_VERIFICATION = 'pending_verification'
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  @Index()
  email!: string;

  @Column()
  @Exclude()
  passwordHash!: string;

  @Column()
  firstName!: string;

  @Column()
  lastName!: string;

  @Column()
  countryCode!: string;

  @Column({ unique: true })
  phoneNumber!: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.BUYER
  })
  role!: UserRole;

  @Column({
    type: 'enum',
    enum: UserStatus,
    default: UserStatus.PENDING_VERIFICATION
  })
  status!: UserStatus;

  @Column({ nullable: true })
  avatarUrl?: string;

  @Column({ nullable: true })
  avatarFileName?: string;

  @Column({ nullable: true })
  company?: string;

  @Column({ nullable: true })
  licenseNumber?: string;

  @Column({ nullable: true })
  subscriptionExpiry?: Date;

  @Column({ nullable: true })
  @Exclude()
  resetPasswordToken?: string;

  @Column({ nullable: true })
  resetPasswordExpires?: Date;

  @Column({ nullable: true })
  emailVerificationToken?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;

  @OneToOne(() => DeveloperProfile, profile => profile.user, { nullable: true })
  developerProfile?: DeveloperProfile;

  @OneToOne(() => BrokerProfile, profile => profile.user, { nullable: true })
  brokerProfile?: BrokerProfile;
} 