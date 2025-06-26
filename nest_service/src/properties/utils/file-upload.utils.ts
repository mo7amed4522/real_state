import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

export function ensurePropertyUploadDir(propertyId: string): string {
  const uploadDir = path.join(__dirname, '..', '..', '..', 'uploads', 'properties', propertyId);
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

export function getPublicFileUrl(propertyId: string, fileName: string): string {
  return `/uploads/properties/${propertyId}/${fileName}`;
} 