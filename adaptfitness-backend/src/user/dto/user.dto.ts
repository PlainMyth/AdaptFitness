/**
 * User Data Transfer Objects
 *
 * These classes define the structure and validation rules for user data. DTOs ensure that incoming user data is properly validated and typed before processing.
 *
 * Key responsibilities:
- Define data structure for user requests\n * - Validate input data using decorators\n * - Provide type safety for user operations\n * - Define response structures for user data
 */

import { IsEmail, IsString, MinLength, IsOptional, IsDateString, IsNumber, IsEnum, IsBoolean } from 'class-validator';

export class CreateUserDto {
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @IsString({ message: 'Password must be a string' })
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  password: string;

  @IsString({ message: 'First name must be a string' })
  firstName: string;

  @IsString({ message: 'Last name must be a string' })
  lastName: string;

  @IsOptional()
  @IsDateString({}, { message: 'Date of birth must be a valid date' })
  dateOfBirth?: string;

  @IsOptional()
  @IsNumber({}, { message: 'Height must be a number' })
  height?: number;

  @IsOptional()
  @IsNumber({}, { message: 'Weight must be a number' })
  weight?: number;

  @IsOptional()
  @IsEnum(['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'], {
    message: 'Activity level must be one of: sedentary, lightly_active, moderately_active, very_active, extremely_active'
  })
  activityLevel?: string;
}

export class UpdateUserDto {
  @IsOptional()
  @IsString({ message: 'First name must be a string' })
  firstName?: string;

  @IsOptional()
  @IsString({ message: 'Last name must be a string' })
  lastName?: string;

  @IsOptional()
  @IsDateString({}, { message: 'Date of birth must be a valid date' })
  dateOfBirth?: string;

  @IsOptional()
  @IsNumber({}, { message: 'Height must be a number' })
  height?: number;

  @IsOptional()
  @IsNumber({}, { message: 'Weight must be a number' })
  weight?: number;

  @IsOptional()
  @IsEnum(['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'], {
    message: 'Activity level must be one of: sedentary, lightly_active, moderately_active, very_active, extremely_active'
  })
  activityLevel?: string;

  @IsOptional()
  @IsBoolean({ message: 'isActive must be a boolean' })
  isActive?: boolean;
}

export class UserResponseDto {
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
