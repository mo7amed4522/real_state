import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateInitialTables1624500000000 implements MigrationInterface {
  name = 'CreateInitialTables1624500000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create users table
    await queryRunner.query(`
      CREATE TYPE "user_role_enum" AS ENUM ('buyer', 'developer', 'broker', 'admin')
    `);

    await queryRunner.query(`
      CREATE TYPE "user_status_enum" AS ENUM ('active', 'blocked', 'pending_verification')
    `);

    await queryRunner.query(`
      CREATE TABLE "users" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "email" character varying NOT NULL,
        "passwordHash" character varying NOT NULL,
        "firstName" character varying NOT NULL,
        "lastName" character varying NOT NULL,
        "phone" character varying,
        "role" "user_role_enum" NOT NULL DEFAULT 'buyer',
        "status" "user_status_enum" NOT NULL DEFAULT 'pending_verification',
        "avatarUrl" character varying,
        "avatarFileName" character varying,
        "company" character varying,
        "licenseNumber" character varying,
        "subscriptionExpiry" TIMESTAMP,
        "resetPasswordToken" character varying,
        "resetPasswordExpires" TIMESTAMP,
        "emailVerificationToken" character varying,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "UQ_users_email" UNIQUE ("email"),
        CONSTRAINT "PK_users" PRIMARY KEY ("id")
      )
    `);

    // Create developer_profiles table
    await queryRunner.query(`
      CREATE TABLE "developer_profiles" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "userId" uuid NOT NULL,
        "company" character varying,
        "licenseNumber" character varying,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_developer_profiles" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_developer_profiles_userId" UNIQUE ("userId"),
        CONSTRAINT "FK_developer_profiles_users" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // Create broker_profiles table
    await queryRunner.query(`
      CREATE TABLE "broker_profiles" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "userId" uuid NOT NULL,
        "company" character varying,
        "licenseNumber" character varying,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_broker_profiles" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_broker_profiles_userId" UNIQUE ("userId"),
        CONSTRAINT "FK_broker_profiles_users" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // Create indexes
    await queryRunner.query(`
      CREATE INDEX "IDX_users_email" ON "users"("email")
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_users_phone" ON "users"("phone")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_users_phone"`);
    await queryRunner.query(`DROP INDEX "IDX_users_email"`);
    await queryRunner.query(`DROP TABLE "broker_profiles"`);
    await queryRunner.query(`DROP TABLE "developer_profiles"`);
    await queryRunner.query(`DROP TABLE "users"`);
    await queryRunner.query(`DROP TYPE "user_status_enum"`);
    await queryRunner.query(`DROP TYPE "user_role_enum"`);
  }
} 