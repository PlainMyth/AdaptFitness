/**
 * Authentication Service
 *
 * This service handles all authentication business logic including user registration,
 * login, password hashing, JWT token generation, and user validation.
 *
 * Key responsibilities:
 * - User registration with password hashing
 * - User login with credential validation
 * - JWT token generation and validation
 * - Password security and hashing
 * - User authentication state management
 */

import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import { RegisterDto, LoginDto, AuthResponseDto, RegisterResponseDto } from './dto/auth.dto';
import { PasswordValidator } from './validators/password.validator';
import * as bcrypt from 'bcryptjs';

// @Injectable decorator makes this class available for dependency injection
@Injectable()
export class AuthService {
  constructor(
    private userService: UserService,    // Service for user database operations
    private jwtService: JwtService,     // Service for JWT token operations
  ) {}

  /**
   * Validate User Credentials
   *
   * Validates a user's email and password against the database.
   * This is used internally by the login process.
   *
   * What it does:
   * 1. Looks up the user by email address
   * 2. Compares the provided password with the hashed password in the database
   * 3. Returns user data (without password) if credentials are valid
   * 4. Returns null if credentials are invalid
   *
   * @param email - User's email address
   * @param password - User's plain text password
   * @returns User data without password, or null if invalid
   */
  async validateUser(email: string, password: string): Promise<any> {
    // Find user by email address - USE ForAuth method to get password hash
    const user = await this.userService.findByEmailForAuth(email);

    // Check if user exists and password matches
    if (user && await bcrypt.compare(password, user.password)) {
      // Remove password from user data before returning
      const { password, ...result } = user;
      return result;
    }

    // Return null if credentials are invalid
    return null;
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.validateUser(loginDto.email, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { email: user.email, sub: user.id };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      }
    };
  }

  async register(registerDto: RegisterDto): Promise<RegisterResponseDto> {
    try {
      // Validate password strength before proceeding
      const passwordValidation = PasswordValidator.validate(registerDto.password);
      if (!passwordValidation.valid) {
        throw new BadRequestException({
          message: 'Password does not meet security requirements',
          errors: passwordValidation.errors,
          requirements: PasswordValidator.getRequirements(),
        });
      }

      // Hash password after validation
      const hashedPassword = await bcrypt.hash(registerDto.password, 10);
      const user = await this.userService.create({
        ...registerDto,
        password: hashedPassword,
      });
      
      const { password, ...result } = user;
      return {
        message: 'User created successfully',
        user: {
          id: result.id,
          email: result.email,
          firstName: result.firstName,
          lastName: result.lastName,
        }
      };
    } catch (error) {
      if (error instanceof ConflictException || error instanceof BadRequestException) {
        throw error;
      }
      throw new Error('Failed to create user');
    }
  }

  async validateToken(userId: string): Promise<any> {
    // Use regular findById since we don't need password for token validation
    const user = await this.userService.findById(userId);
    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }
    return user;
  }
}
