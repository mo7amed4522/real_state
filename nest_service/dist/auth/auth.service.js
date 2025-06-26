"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var _a, _b, _c, _d;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const path = require("path");
const fs = require("fs");
const user_entity_1 = require("./entities/user.entity");
const developer_profile_entity_1 = require("./entities/developer-profile.entity");
const broker_profile_entity_1 = require("./entities/broker-profile.entity");
const file_upload_utils_1 = require("./utils/file-upload.utils");
let AuthService = class AuthService {
    constructor(userRepository, developerProfileRepository, brokerProfileRepository, jwtService) {
        this.userRepository = userRepository;
        this.developerProfileRepository = developerProfileRepository;
        this.brokerProfileRepository = brokerProfileRepository;
        this.jwtService = jwtService;
    }
    async register(registerDto) {
        const { email, password, role, ...userData } = registerDto;
        const existingUser = await this.userRepository.findOneBy({ email });
        if (existingUser) {
            throw new common_1.ConflictException('User already exists');
        }
        const passwordHash = await bcrypt.hash(password, 10);
        const userToCreate = {
            email,
            passwordHash,
            role,
            status: user_entity_1.UserStatus.PENDING_VERIFICATION,
            ...userData,
        };
        const savedUser = await this.userRepository.save(this.userRepository.create(userToCreate));
        if (role === user_entity_1.UserRole.DEVELOPER) {
            const { company, ...profileData } = userData;
            await this.developerProfileRepository.save(this.developerProfileRepository.create({
                userId: savedUser.id,
                companyName: company,
                ...profileData,
            }));
        }
        else if (role === user_entity_1.UserRole.BROKER) {
            const { company, ...profileData } = userData;
            await this.brokerProfileRepository.save(this.brokerProfileRepository.create({
                userId: savedUser.id,
                companyName: company,
                ...profileData,
            }));
        }
        return this.generateToken(savedUser);
    }
    async uploadUserPhoto(userId, file) {
        const user = await this.findUserById(userId);
        const uploadDir = (0, file_upload_utils_1.ensureUserUploadDir)(userId);
        const encryptedFileName = (0, file_upload_utils_1.generateEncryptedFileName)(file.originalname, userId);
        const filePath = path.join(uploadDir, encryptedFileName);
        if (user.avatarFileName) {
            const oldFilePath = path.join(uploadDir, user.avatarFileName);
            if (fs.existsSync(oldFilePath)) {
                fs.unlinkSync(oldFilePath);
            }
        }
        fs.writeFileSync(filePath, file.buffer);
        user.avatarFileName = encryptedFileName;
        user.avatarUrl = (0, file_upload_utils_1.getPublicFileUrl)(userId, encryptedFileName);
        return this.userRepository.save(user);
    }
    async updateUser(userId, updateDto) {
        const user = await this.findUserById(userId);
        Object.assign(user, updateDto);
        return this.userRepository.save(user);
    }
    async changePassword(userId, dto) {
        const user = await this.findUserById(userId);
        const isValid = await bcrypt.compare(dto.currentPassword, user.passwordHash);
        if (!isValid) {
            throw new common_1.UnauthorizedException('Current password is incorrect');
        }
        user.passwordHash = await bcrypt.hash(dto.newPassword, 10);
        return this.userRepository.save(user);
    }
    async forgotPassword(email) {
        const user = await this.userRepository.findOneBy({ email });
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const token = crypto.randomBytes(32).toString('hex');
        const expiryDate = new Date();
        expiryDate.setHours(expiryDate.getHours() + 1);
        user.resetPasswordToken = token;
        user.resetPasswordExpires = expiryDate;
        await this.userRepository.save(user);
        return { message: 'Password reset email sent' };
    }
    async resetPassword(dto) {
        const user = await this.userRepository.findOne({
            where: {
                resetPasswordToken: dto.token,
                resetPasswordExpires: (0, typeorm_2.MoreThan)(new Date()),
            },
        });
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid or expired reset token');
        }
        user.passwordHash = await bcrypt.hash(dto.newPassword, 10);
        user.resetPasswordToken = undefined;
        user.resetPasswordExpires = undefined;
        return this.userRepository.save(user);
    }
    async searchUsers(searchDto) {
        const where = {};
        if (searchDto.search) {
            where.firstName = (0, typeorm_2.ILike)(`%${searchDto.search}%`);
        }
        if (searchDto.role) {
            where.role = searchDto.role;
        }
        return this.userRepository.find({
            where,
            select: ['id', 'email', 'firstName', 'lastName', 'role', 'status', 'avatarUrl'],
        });
    }
    async findUserById(id) {
        const user = await this.userRepository.findOneBy({ id });
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        return user;
    }
    async login(email, password) {
        const user = await this.userRepository.findOneBy({ email });
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        return this.generateToken(user);
    }
    generateToken(user) {
        const payload = { sub: user.id, email: user.email, role: user.role };
        return {
            access_token: this.jwtService.sign(payload),
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
                status: user.status,
                avatarUrl: user.avatarUrl,
            },
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(developer_profile_entity_1.DeveloperProfile)),
    __param(2, (0, typeorm_1.InjectRepository)(broker_profile_entity_1.BrokerProfile)),
    __metadata("design:paramtypes", [typeof (_a = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _a : Object, typeof (_b = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _b : Object, typeof (_c = typeof typeorm_2.Repository !== "undefined" && typeorm_2.Repository) === "function" ? _c : Object, typeof (_d = typeof jwt_1.JwtService !== "undefined" && jwt_1.JwtService) === "function" ? _d : Object])
], AuthService);
//# sourceMappingURL=auth.service.js.map