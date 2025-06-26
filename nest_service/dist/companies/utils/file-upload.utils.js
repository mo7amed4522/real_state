"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureCompanyUploadDir = ensureCompanyUploadDir;
exports.generateEncryptedFileName = generateEncryptedFileName;
exports.getPublicFileUrl = getPublicFileUrl;
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
function ensureCompanyUploadDir(companyId) {
    const uploadDir = path.join(__dirname, '..', '..', '..', 'uploads', 'companies', companyId);
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
function getPublicFileUrl(companyId, fileName) {
    return `/uploads/companies/${companyId}/${fileName}`;
}
//# sourceMappingURL=file-upload.utils.js.map