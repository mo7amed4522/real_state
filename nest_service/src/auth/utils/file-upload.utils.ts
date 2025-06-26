import * as crypto from 'crypto';
import * as path from 'path';
import * as fs from 'fs';

export const generateEncryptedFileName = (originalName: string, userId: string): string => {
  const fileExt = path.extname(originalName);
  const timestamp = Date.now();
  const hash = crypto
    .createHash('sha256')
    .update(`${userId}-${timestamp}-${originalName}`)
    .digest('hex');
  return `${hash}${fileExt}`;
};

export const ensureUserUploadDir = (userId: string): string => {
  const uploadDir = path.join(process.cwd(), 'uploads', 'users', userId);
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }
  return uploadDir;
};

export const getPublicFileUrl = (userId: string, fileName: string): string => {
  return `/uploads/users/${userId}/${fileName}`;
}; 