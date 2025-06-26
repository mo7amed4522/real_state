import { UserRole } from '../entities/user.entity';
export declare class RegisterUserDto {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phone?: string;
    role: UserRole;
    company?: string;
    licenseNumber?: string;
}
export declare class UpdateUserDto {
    firstName?: string;
    lastName?: string;
    phone?: string;
    company?: string;
    licenseNumber?: string;
}
export declare class ChangePasswordDto {
    currentPassword: string;
    newPassword: string;
}
export declare class ResetPasswordDto {
    newPassword: string;
    token: string;
}
export declare class ForgotPasswordDto {
    email: string;
}
export declare class SearchUsersDto {
    search?: string;
    role?: UserRole;
}
