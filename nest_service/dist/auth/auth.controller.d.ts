import { AuthService } from './auth.service';
import { RegisterUserDto, UpdateUserDto, ChangePasswordDto, ResetPasswordDto, SearchUsersDto, ForgotPasswordDto } from './dto/user.dto';
interface FileUpload {
    buffer: Buffer;
    originalname: string;
}
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(registerDto: RegisterUserDto): unknown;
    login(loginDto: {
        email: string;
        password: string;
    }): unknown;
    uploadPhoto(req: any, file: FileUpload): unknown;
    updateProfile(req: any, updateDto: UpdateUserDto): unknown;
    changePassword(req: any, changePasswordDto: ChangePasswordDto): unknown;
    forgotPassword(forgotPasswordDto: ForgotPasswordDto): unknown;
    resetPassword(resetPasswordDto: ResetPasswordDto): unknown;
    searchUsers(searchDto: SearchUsersDto): unknown;
    getUser(id: string): unknown;
    getProfile(req: any): unknown;
}
export {};
