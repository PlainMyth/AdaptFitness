/**
 * Authentication Controller
 *
 * This controller handles all HTTP requests related to authentication.
 * It provides endpoints for user registration, login, profile access,
 * and token validation.
 *
 * Key responsibilities:
 * - Handle user registration and login
 * - Provide user profile information
 * - Validate JWT tokens
 * - Manage authentication state
 */

import { Controller, Post, Body, ValidationPipe, Get, UseGuards, Request } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, AuthResponseDto, RegisterResponseDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { authThrottlerConfig } from '../config/throttler.config';

// @Controller decorator with 'auth' prefix means all routes start with /auth
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  /**
   * POST /auth/register
   *
   * Creates a new user account
   *
   * What it does:
   * 1. Validates the registration data (email, password, name, etc.)
   * 2. Checks if email is already taken
   * 3. Hashes the password for security
   * 4. Creates the user account in the database
   * 5. Returns user information (without password)
   *
   * @param registerDto - User registration data (email, password, name, etc.)
   * @returns User information and success message
   *
   * Example request body:
   * {
   *   "email": "user@example.com",
   *   "password": "securePassword123",
   *   "firstName": "John",
   *   "lastName": "Doe",
   *   "dateOfBirth": "1995-01-01",
   *   "height": 175,
   *   "gender": "male"
   * }
   */
  @Post('register')
  @Throttle({ default: { limit: authThrottlerConfig.limit, ttl: authThrottlerConfig.ttl } })
  async register(@Body(ValidationPipe) registerDto: RegisterDto): Promise<RegisterResponseDto> {
    return this.authService.register(registerDto);
  }

  /**
   * POST /auth/login
   *
   * Authenticates a user and returns a JWT token
   *
   * What it does:
   * 1. Validates the login credentials (email and password)
   * 2. Checks if the user exists and password is correct
   * 3. Generates a JWT token for authentication
   * 4. Returns the token and user information
   *
   * @param loginDto - User login credentials (email and password)
   * @returns JWT token and user information
   *
   * Example request body:
   * {
   *   "email": "user@example.com",
   *   "password": "securePassword123"
   * }
   *
   * Example response:
   * {
   *   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
   *   "user": {
   *     "id": "123e4567-e89b-12d3-a456-426614174000",
   *     "email": "user@example.com",
   *     "firstName": "John",
   *     "lastName": "Doe"
   *   }
   * }
   */
  @Post('login')
  @Throttle({ default: { limit: authThrottlerConfig.limit, ttl: authThrottlerConfig.ttl } })
  async login(@Body(ValidationPipe) loginDto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(loginDto);
  }

  /**
   * GET /auth/profile
   *
   * Gets the current user's profile information
   *
   * What it does:
   * 1. Requires a valid JWT token in the Authorization header
   * 2. Extracts user information from the token
   * 3. Returns the user's profile data
   *
   * @param req - Request object containing user information from JWT token
   * @returns User profile information
   *
   * Headers required:
   * Authorization: Bearer <jwt_token>
   */
  @UseGuards(JwtAuthGuard) // This endpoint requires authentication
  @Get('profile')
  async getProfile(@Request() req) {
    return {
      id: req.user.id,                    // User's unique ID
      email: req.user.email,              // User's email address
      firstName: req.user.firstName,      // User's first name
      lastName: req.user.lastName,        // User's last name
      fullName: req.user.fullName,        // User's full name (computed)
      isActive: req.user.isActive,        // Whether the account is active
    };
  }

  /**
   * GET /auth/validate
   *
   * Validates a JWT token and returns user information
   *
   * What it does:
   * 1. Checks if the provided JWT token is valid
   * 2. Extracts user information from the token
   * 3. Returns validation status and user data
   *
   * This endpoint is useful for:
   * - Checking if a token is still valid
   * - Getting user info without making a full profile request
   * - Frontend authentication state management
   *
   * @param req - Request object containing user information from JWT token
   * @returns Token validation status and user information
   *
   * Headers required:
   * Authorization: Bearer <jwt_token>
   */
  @UseGuards(JwtAuthGuard) // This endpoint requires authentication
  @Get('validate')
  async validate(@Request() req) {
    return {
      valid: true,                        // Token is valid
      user: {
        id: req.user.id,                  // User's unique ID
        email: req.user.email,            // User's email address
        firstName: req.user.firstName,    // User's first name
        lastName: req.user.lastName,      // User's last name
      }
    };
  }
}
