"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPublicFileUrl = exports.ensureUserUploadDir = exports.generateEncryptedFileName = void 0;
const crypto = require("crypto");
const path = require("path");
const fs = require("fs");
const generateEncryptedFileName = (originalName, userId) => {
    const fileExt = path.extname(originalName);
    const timestamp = Date.now();
    const hash = crypto
        .createHash('sha256')
        .update(`${userId}-${timestamp}-${originalName}`)
        .digest('hex');
    return `${hash}${fileExt}`;
};
exports.generateEncryptedFileName = generateEncryptedFileName;
const ensureUserUploadDir = (userId) => {
    const uploadDir = path.join(process.cwd(), 'uploads', 'users', userId);
    if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
    }
    return uploadDir;
};
exports.ensureUserUploadDir = ensureUserUploadDir;
const getPublicFileUrl = (userId, fileName) => {
    return `/uploads/users/${userId}/${fileName}`;
};
exports.getPublicFileUrl = getPublicFileUrl;
//# sourceMappingURL=file-upload.utils.js.map