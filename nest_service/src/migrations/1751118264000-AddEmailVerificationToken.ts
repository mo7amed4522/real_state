import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddEmailVerificationToken1751118264000 implements MigrationInterface {
  name = 'AddEmailVerificationToken1751118264000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add emailVerificationToken column to users table
    await queryRunner.query(`
      ALTER TABLE "users" 
      ADD COLUMN "emailVerificationToken" character varying
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove emailVerificationToken column from users table
    await queryRunner.query(`
      ALTER TABLE "users" 
      DROP COLUMN "emailVerificationToken"
    `);
  }
} 