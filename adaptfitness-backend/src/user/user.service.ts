/**
 * User Service
 *
 * This service handles all user-related business logic and database operations.
 * It provides CRUD operations for users and manages user data validation.
 *
 * Key responsibilities:
 * - Create, read, update, and delete users
 * - Validate user data and handle conflicts
 * - Convert user entities to response DTOs
 * - Manage user authentication data
 */

import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { CreateUserDto, UpdateUserDto, UserResponseDto } from './dto/user.dto';

// @Injectable decorator makes this class available for dependency injection
@Injectable()
export class UserService {
  constructor(
    // Inject the User repository - this gives us access to the database
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  /**
   * CREATE - Creates a new user
   *
   * What it does:
   * 1. Checks if a user with the same email already exists
   * 2. Throws an error if email is already taken
   * 3. Creates a new user record in the database
   * 4. Returns the created user
   *
   * @param createUserDto - User data for creation
   * @returns The created user
   * @throws ConflictException if email already exists
   */
  async create(createUserDto: CreateUserDto): Promise<User> {
    // Check if user with this email already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: createUserDto.email }
    });

    // Throw error if email is already taken
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Create new user entity and save to database
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }

  /**
   * FOR AUTHENTICATION ONLY - includes password hash
   * This method is used during login to verify credentials.
   * NEVER use this method for general user queries.
   */
  async findByEmailForAuth(email: string): Promise<User | undefined> {
    return this.userRepository.findOne({ where: { email } });
  }

  /**
   * FOR GENERAL USE - excludes password hash
   * Use this method for all non-authentication queries.
   */
  async findByEmail(email: string): Promise<User | undefined> {
    return this.userRepository.findOne({ 
      where: { email },
      select: ['id', 'email', 'firstName', 'lastName', 'dateOfBirth', 'height', 'weight', 'gender', 'activityLevel', 'activityLevelMultiplier', 'isActive', 'createdAt', 'updatedAt']
    });
  }

  /**
   * FOR AUTHENTICATION ONLY - includes password hash
   * This method is used during JWT validation.
   * NEVER use this method for general user queries.
   */
  async findByIdForAuth(id: string): Promise<User | undefined> {
    return this.userRepository.findOne({ where: { id } });
  }

  /**
   * FOR GENERAL USE - excludes password hash
   * Use this method for all non-authentication queries.
   */
  async findById(id: string): Promise<User | undefined> {
    return this.userRepository.findOne({ 
      where: { id },
      select: ['id', 'email', 'firstName', 'lastName', 'dateOfBirth', 'height', 'weight', 'gender', 'activityLevel', 'activityLevelMultiplier', 'isActive', 'createdAt', 'updatedAt']
    });
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    Object.assign(user, updateUserDto);
    return this.userRepository.save(user);
  }

  async delete(id: string): Promise<void> {
    const result = await this.userRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('User not found');
    }
  }

  async findAll(): Promise<User[]> {
    return this.userRepository.find({
      select: ['id', 'email', 'firstName', 'lastName', 'isActive', 'createdAt', 'updatedAt']
    });
  }

  // Helper method to convert User entity to response DTO
  toResponseDto(user: User): UserResponseDto {
    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      dateOfBirth: user.dateOfBirth,
      height: user.height,
      weight: user.weight,
      bmi: user.bmi,
      activityLevel: user.activityLevel,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}
