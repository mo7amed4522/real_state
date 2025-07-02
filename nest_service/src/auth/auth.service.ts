import { Injectable, UnauthorizedException, ConflictException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere, DeepPartial, Like, ILike, MoreThan } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import * as path from 'path';
import * as fs from 'fs';
import { User, UserRole, UserStatus } from './entities/user.entity';
import { DeveloperProfile } from './entities/developer-profile.entity';
import { BrokerProfile } from './entities/broker-profile.entity';
import { RegisterUserDto, UpdateUserDto, ChangePasswordDto, ResetPasswordDto, SearchUsersDto } from './dto/user.dto';
import { generateEncryptedFileName, ensureUserUploadDir, getPublicFileUrl } from './utils/file-upload.utils';
import { hashString } from './utils/hash.utils';
import { extname, join } from 'path';
import { promises as fsPromises } from 'fs';

interface FileUpload {
  buffer: Buffer;
  originalname: string;
}

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(DeveloperProfile)
    private readonly developerProfileRepository: Repository<DeveloperProfile>,
    @InjectRepository(BrokerProfile)
    private readonly brokerProfileRepository: Repository<BrokerProfile>,
    private readonly jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterUserDto) {
    const { email, password, role, ...userData } = registerDto;

    const existingUser = await this.userRepository.findOneBy({ email });
    if (existingUser) {
      throw new ConflictException('User already exists');
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const emailVerificationToken = crypto.randomBytes(32).toString('hex');

    const userToCreate: DeepPartial<User> = {
      email,
      passwordHash,
      role,
      status: UserStatus.PENDING_VERIFICATION,
      emailVerificationToken,
      ...userData,
    };
    
    const savedUser = await this.userRepository.save(this.userRepository.create(userToCreate));

    if (role === UserRole.DEVELOPER) {
      const { company, ...profileData } = userData;
      await this.developerProfileRepository.save(
        this.developerProfileRepository.create({
          userId: savedUser.id,
          companyName: company,
          ...profileData,
        })
      );
    } else if (role === UserRole.BROKER) {
      const { company, ...profileData } = userData;
      await this.brokerProfileRepository.save(
        this.brokerProfileRepository.create({
          userId: savedUser.id,
          companyName: company,
          ...profileData,
        })
      );
    }

    // For now, return the verification token in the response for testing
    return {
      ...this.generateToken(savedUser),
      emailVerificationToken,
      testEmail: 'eng.khaled4522@gmail.com',
    };
  }

  async uploadUserPhoto(userId: string, file: Express.Multer.File) {
    const folderName = hashString(userId);
    const ext = extname(file.originalname);
    const fileName = hashString(file.originalname + Date.now()) + ext;
    const uploadDir = join(process.cwd(), 'uploads', 'users', folderName);
    await fsPromises.mkdir(uploadDir, { recursive: true });
    const filePath = join(uploadDir, fileName);
    await fsPromises.writeFile(filePath, file.buffer);
    
    // Generate URL using the controller endpoint
    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    const photoUrl = `${baseUrl}/auth/user-photo/${folderName}/${fileName}`;
    
    // Save URL to user in database
    await this.userRepository.update(userId, { 
      avatarUrl: photoUrl,
      avatarFileName: fileName 
    });
    
    return { url: photoUrl };
  }

  async updateUser(userId: string, updateDto: UpdateUserDto) {
    const user = await this.findUserById(userId);
    Object.assign(user, updateDto);
    return this.userRepository.save(user);
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.findUserById(userId);
    
    const isValid = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    user.passwordHash = await bcrypt.hash(dto.newPassword, 10);
    return this.userRepository.save(user);
  }

  async forgotPassword(email: string) {
    const user = await this.userRepository.findOneBy({ email });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const token = crypto.randomBytes(32).toString('hex');
    const expiryDate = new Date();
    expiryDate.setHours(expiryDate.getHours() + 1); // Token expires in 1 hour

    user.resetPasswordToken = token;
    user.resetPasswordExpires = expiryDate;
    await this.userRepository.save(user);

    // TODO: Send email with reset token
    return { message: 'Password reset email sent' };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const user = await this.userRepository.findOne({
      where: {
        resetPasswordToken: dto.token,
        resetPasswordExpires: MoreThan(new Date()),
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid or expired reset token');
    }

    user.passwordHash = await bcrypt.hash(dto.newPassword, 10);
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    
    return this.userRepository.save(user);
  }

  async searchUsers(searchDto: SearchUsersDto) {
    const where: FindOptionsWhere<User> = {};
    
    if (searchDto.search) {
      where.firstName = ILike(`%${searchDto.search}%`);
      // Add more search fields as needed
    }
    
    if (searchDto.role) {
      where.role = searchDto.role;
    }

    return this.userRepository.find({
      where,
      select: ['id', 'email', 'firstName', 'lastName', 'role', 'status', 'avatarUrl'],
    });
  }

  async findUserById(id: string) {
    const user = await this.userRepository.findOneBy({ id });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async login(email: string, password: string) {
    const user = await this.userRepository.findOneBy({ email });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.generateToken(user);
  }

  private generateToken(user: User) {
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

  async verifyEmail(token: string) {
    const user = await this.userRepository.findOneBy({ emailVerificationToken: token });
    if (!user) {
      throw new NotFoundException('Invalid or expired verification token');
    }
    user.status = UserStatus.ACTIVE;
    user.emailVerificationToken = undefined;
    await this.userRepository.save(user);
    return { message: 'Email verified successfully', email: user.email };
  }
} 