import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Workout } from './workout.entity';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';

/**
 * Workout Service
 *
 * This service handles all workout-related business logic and database operations.
 * It provides CRUD operations for workouts and manages workout data validation.
 *
 * Key responsibilities:
 * - Create, read, update, and delete workouts
 * - Validate workout data and handle conflicts
 * - Convert workout entities to response DTOs
 * - Manage workout streak calculations
 * - Handle timezone-aware date calculations
 */
@Injectable()
export class WorkoutService {
  constructor(
    @InjectRepository(Workout)
    private workoutRepository: Repository<Workout>,
  ) {}

  /**
   * Validate create workout DTO
   * @param dto - The DTO to validate
   * @throws BadRequestException if validation fails
   */
  private validateCreateWorkoutDto(dto: CreateWorkoutDto): void {
    if (!dto.name || dto.name.trim().length === 0) {
      throw new BadRequestException('Workout name is required.');
    }
    if (!dto.startTime) {
      throw new BadRequestException('Workout start time is required.');
    }
    if (dto.totalCaloriesBurned !== undefined && dto.totalCaloriesBurned < 0) {
      throw new BadRequestException('Total calories burned cannot be negative.');
    }
    if (dto.totalDuration !== undefined && dto.totalDuration < 0) {
      throw new BadRequestException('Total duration cannot be negative.');
    }
    if (!dto.userId || dto.userId.trim().length === 0) {
      throw new BadRequestException('User ID is required for workout creation.');
    }
  }

  /**
   * Validate update workout DTO
   * @param dto - The DTO to validate
   * @throws BadRequestException if validation fails
   */
  private validateUpdateWorkoutDto(dto: UpdateWorkoutDto): void {
    if (dto.name !== undefined && dto.name.trim().length === 0) {
      throw new BadRequestException('Workout name cannot be empty.');
    }
    if (dto.totalCaloriesBurned !== undefined && dto.totalCaloriesBurned < 0) {
      throw new BadRequestException('Total calories burned cannot be negative.');
    }
    if (dto.totalDuration !== undefined && dto.totalDuration < 0) {
      throw new BadRequestException('Total duration cannot be negative.');
    }
  }

  /**
   * Create a new workout
   * @param createWorkoutDto - The workout data to create
   * @returns The created workout
   */
  async create(createWorkoutDto: CreateWorkoutDto): Promise<Workout> {
    this.validateCreateWorkoutDto(createWorkoutDto);
    const workout = this.workoutRepository.create(createWorkoutDto);
    return await this.workoutRepository.save(workout);
  }

  /**
   * Find all workouts for a specific user
   * @param userId - The user ID to find workouts for
   * @returns Array of workouts for the user
   */
  async findAll(userId: string): Promise<Workout[]> {
    return await this.workoutRepository.find({
      where: { user: { id: userId } },
      order: { startTime: 'DESC' },
    });
  }

  /**
   * Find a specific workout by ID
   * @param id - The workout ID
   * @returns The workout if found
   * @throws NotFoundException if workout not found
   */
  async findOne(id: string): Promise<Workout> {
    const workout = await this.workoutRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!workout) {
      throw new NotFoundException(`Workout with ID ${id} not found`);
    }

    return workout;
  }

  /**
   * Update a workout
   * @param id - The workout ID to update
   * @param updateWorkoutDto - The updated workout data
   * @returns The updated workout
   * @throws NotFoundException if workout not found
   */
  async update(id: string, updateWorkoutDto: UpdateWorkoutDto): Promise<Workout> {
    this.validateUpdateWorkoutDto(updateWorkoutDto);
    const workout = await this.findOne(id);
    
    Object.assign(workout, updateWorkoutDto);
    return await this.workoutRepository.save(workout);
  }

  /**
   * Remove a workout
   * @param id - The workout ID to remove
   * @throws NotFoundException if workout not found
   */
  async remove(id: string): Promise<void> {
    const workout = await this.findOne(id);
    await this.workoutRepository.remove(workout);
  }

  /**
   * Get current workout streak for a user in a specific timezone
   * @param userId - The user ID
   * @param timeZone - The timezone to calculate streak in (optional, defaults to UTC)
   * @returns Object containing streak count and last workout date
   */
  async getCurrentStreakInTimeZone(userId: string, timeZone?: string): Promise<{ streak: number; lastWorkoutDate: string | null }> {
    const workouts = await this.workoutRepository.find({
      where: { user: { id: userId } },
      order: { startTime: 'DESC' },
    });

    if (workouts.length === 0) {
      return { streak: 0, lastWorkoutDate: null };
    }

    const timeZoneToUse = timeZone || 'UTC';
    const todayKey = this.getDateKeyInTimeZone(new Date(), timeZoneToUse);
    let streak = 0;
    let currentDateKey = todayKey;

    // Check if there's a workout today
    const hasWorkoutToday = workouts.some(workout => 
      workout.startTime && this.getDateKeyInTimeZone(workout.startTime, timeZoneToUse) === todayKey
    );

    if (!hasWorkoutToday) {
      // If no workout today, start checking from yesterday
      currentDateKey = this.getKeyForDaysAgo(1, timeZoneToUse);
    }

    // Count consecutive days with workouts
    for (let daysAgo = 0; daysAgo < 365; daysAgo++) {
      const dateKey = this.getKeyForDaysAgo(daysAgo, timeZoneToUse);
      const hasWorkoutOnDate = workouts.some(workout => 
        workout.startTime && this.getDateKeyInTimeZone(workout.startTime, timeZoneToUse) === dateKey
      );

      if (hasWorkoutOnDate) {
        streak++;
      } else {
        break;
      }
    }

    // Find the most recent workout date
    const lastWorkout = workouts.find(workout => workout.startTime);
    const lastWorkoutDate = lastWorkout ? 
      this.getDateKeyInTimeZone(lastWorkout.startTime, timeZoneToUse) : null;

    return { streak, lastWorkoutDate };
  }

  /**
   * Get date key in a specific timezone
   * @param date - The date to convert
   * @param timeZone - The target timezone
   * @returns Date string in YYYY-MM-DD format
   */
  private getDateKeyInTimeZone(date: Date, timeZone: string): string {
    try {
      const formatter = new Intl.DateTimeFormat('en-CA', {
        timeZone: timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      });
      
      const parts = formatter.formatToParts(date);
      const year = parts.find(p => p.type === 'year')?.value ?? '2025';
      const month = parts.find(p => p.type === 'month')?.value ?? '01';
      const day = parts.find(p => p.type === 'day')?.value ?? '01';
      return `${year}-${month}-${day}`;
    } catch (error) {
      // Fallback to UTC if timezone is invalid
      const year = date.getUTCFullYear();
      const month = String(date.getUTCMonth() + 1).padStart(2, '0');
      const day = String(date.getUTCDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    }
  }

  /**
   * Get date key for a specific number of days ago
   * @param daysAgo - Number of days to go back
   * @param timeZone - The timezone to calculate in
   * @returns Date string in YYYY-MM-DD format
   */
  private getKeyForDaysAgo(daysAgo: number, timeZone: string): string {
    // Determine the user's current local date first
    const now = new Date();
    const todayKey = this.getDateKeyInTimeZone(now, timeZone);
    const [y, m, d] = todayKey.split('-').map(Number);
    // Create a date at local midnight, then step back daysAgo
    const base = new Date(y, m - 1, d);
    const stepped = new Date(base.getTime() - daysAgo * 24 * 60 * 60 * 1000);
    return this.getDateKeyInTimeZone(stepped, timeZone);
  }
}