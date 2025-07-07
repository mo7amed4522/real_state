import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

export function ensureCompanyUploadDir(companyId: string): string {
  const uploadDir = path.join(__dirname, '..', '..', '..', 'uploads', 'companies', companyId);
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }
  return uploadDir;
}

export function generateEncryptedFileName(originalName: string): string {
  const ext = path.extname(originalName);
  const base = crypto.randomBytes(16).toString('hex');
  return `${base}${ext}`;
}

export function getPublicFileUrl(companyId: string, fileName: string): string {
  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  return `${baseUrl}/companies/logo/${companyId}/${fileName}`;
}

export function getFullLogoUrl(companyId: string, fileName: string): string {
  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  return `${baseUrl}/companies/logo/${companyId}/${fileName}`;
}

// For backward compatibility - returns the old URL pattern
export function getLegacyLogoUrl(companyId: string, fileName: string): string {
  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  return `${baseUrl}/uploads/companies/${companyId}/${fileName}`;
} 