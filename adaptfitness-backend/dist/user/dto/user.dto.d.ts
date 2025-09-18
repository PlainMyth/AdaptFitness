export declare class CreateUserDto {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    dateOfBirth?: string;
    height?: number;
    weight?: number;
    activityLevel?: string;
}
export declare class UpdateUserDto {
    firstName?: string;
    lastName?: string;
    dateOfBirth?: string;
    height?: number;
    weight?: number;
    activityLevel?: string;
    isActive?: boolean;
}
export declare class UserResponseDto {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    fullName: string;
    dateOfBirth?: Date;
    height?: number;
    weight?: number;
    bmi?: number;
    activityLevel?: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
