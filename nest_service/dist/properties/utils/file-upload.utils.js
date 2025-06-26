"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensurePropertyUploadDir = ensurePropertyUploadDir;
exports.generateEncryptedFileName = generateEncryptedFileName;
exports.getPublicFileUrl = getPublicFileUrl;
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
function ensurePropertyUploadDir(propertyId) {
    const uploadDir = path.join(__dirname, '..', '..', '..', 'uploads', 'properties', propertyId);
    if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
    }
    return uploadDir;
}
function generateEncryptedFileName(originalName) {
    const ext = path.extname(originalName);
    const base = crypto.randomBytes(16).toString('hex');
    return `${base}${ext}`;
}
function getPublicFileUrl(propertyId, fileName) {
    return `/uploads/properties/${propertyId}/${fileName}`;
}
//# sourceMappingURL=file-upload.utils.js.map