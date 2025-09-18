/**
 * Authentication Data Transfer Objects
 *
 * These classes define the structure and validation rules for authentication data. DTOs ensure that incoming data is properly validated and typed before processing.
 *
 * Key responsibilities:
- Define data structure for authentication requests\n * - Validate input data using decorators\n * - Provide type safety for authentication operations\n * - Define response structures for API responses
 */

import { IsEmail, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @IsString({ message: 'Password must be a string' })
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  password: string;

  @IsString({ message: 'First name must be a string' })
  firstName: string;

  @IsString({ message: 'Last name must be a string' })
  lastName: string;
}

export class LoginDto {
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @IsString({ message: 'Password must be a string' })
  password: string;
}

export class AuthResponseDto {
  access_token: string;
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  };
}

export class RegisterResponseDto {
  message: string;
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  };
}
