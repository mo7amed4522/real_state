import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { DeveloperProfile } from './entities/developer-profile.entity';
import { BrokerProfile } from './entities/broker-profile.entity';
import { RegisterUserDto, UpdateUserDto, ChangePasswordDto, ResetPasswordDto, SearchUsersDto } from './dto/user.dto';
interface FileUpload {
    buffer: Buffer;
    originalname: string;
}
export declare class AuthService {
    private readonly userRepository;
    private readonly developerProfileRepository;
    private readonly brokerProfileRepository;
    private readonly jwtService;
    constructor(userRepository: Repository<User>, developerProfileRepository: Repository<DeveloperProfile>, brokerProfileRepository: Repository<BrokerProfile>, jwtService: JwtService);
    register(registerDto: RegisterUserDto): unknown;
    uploadUserPhoto(userId: string, file: FileUpload): unknown;
    updateUser(userId: string, updateDto: UpdateUserDto): unknown;
    changePassword(userId: string, dto: ChangePasswordDto): unknown;
    forgotPassword(email: string): unknown;
    resetPassword(dto: ResetPasswordDto): unknown;
    searchUsers(searchDto: SearchUsersDto): unknown;
    findUserById(id: string): unknown;
    login(email: string, password: string): unknown;
    private generateToken;
}
export {};
