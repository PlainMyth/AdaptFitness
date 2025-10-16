import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Meal } from './meal.entity';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';

/**
 * Meal Service
 *
 * This service handles all meal-related business logic and database operations.
 * It provides CRUD operations for meals and manages meal data validation.
 *
 * Key responsibilities:
 * - Create, read, update, and delete meals
 * - Validate meal data and handle conflicts
 * - Convert meal entities to response DTOs
 * - Manage meal streak calculations
 * - Handle timezone-aware date calculations
 */
@Injectable()
export class MealService {
  constructor(
    @InjectRepository(Meal)
    private mealRepository: Repository<Meal>,
  ) {}

  /**
   * Create a new meal
   * @param createMealDto - The meal data to create
   * @returns The created meal
   */
  async create(createMealDto: CreateMealDto): Promise<Meal> {
    // Validate input data
    this.validateCreateMealDto(createMealDto);
    
    const meal = this.mealRepository.create(createMealDto);
    return await this.mealRepository.save(meal);
  }

  /**
   * Find all meals for a specific user
   * @param userId - The user ID to find meals for
   * @returns Array of meals for the user
   */
  async findAll(userId: string): Promise<Meal[]> {
    return await this.mealRepository.find({
      where: { user: { id: userId } },
      order: { mealTime: 'DESC' },
    });
  }

  /**
   * Find a specific meal by ID
   * @param id - The meal ID
   * @returns The meal if found
   * @throws NotFoundException if meal not found
   */
  async findOne(id: string): Promise<Meal> {
    const meal = await this.mealRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!meal) {
      throw new NotFoundException(`Meal with ID ${id} not found`);
    }

    return meal;
  }

  /**
   * Update a meal
   * @param id - The meal ID to update
   * @param updateMealDto - The updated meal data
   * @returns The updated meal
   * @throws NotFoundException if meal not found
   */
  async update(id: string, updateMealDto: UpdateMealDto): Promise<Meal> {
    // Validate input data
    this.validateUpdateMealDto(updateMealDto);
    
    const meal = await this.findOne(id);
    
    Object.assign(meal, updateMealDto);
    return await this.mealRepository.save(meal);
  }

  /**
   * Remove a meal
   * @param id - The meal ID to remove
   * @throws NotFoundException if meal not found
   */
  async remove(id: string): Promise<void> {
    const meal = await this.findOne(id);
    await this.mealRepository.remove(meal);
  }

  /**
   * Get current meal streak for a user in a specific timezone
   * @param userId - The user ID
   * @param timeZone - The timezone to calculate streak in (optional, defaults to UTC)
   * @returns Object containing streak count and last meal date
   */
  async getCurrentStreakInTimeZone(userId: string, timeZone?: string): Promise<{ streak: number; lastMealDate: string | null }> {
    const meals = await this.mealRepository.find({
      where: { user: { id: userId } },
      order: { mealTime: 'DESC' },
    });

    if (meals.length === 0) {
      return { streak: 0, lastMealDate: null };
    }

    const timeZoneToUse = timeZone || 'UTC';
    const todayKey = this.getDateKeyInTimeZone(new Date(), timeZoneToUse);
    let streak = 0;
    let currentDateKey = todayKey;

    // Check if there's a meal today
    const hasMealToday = meals.some(meal => 
      meal.mealTime && this.getDateKeyInTimeZone(meal.mealTime, timeZoneToUse) === todayKey
    );

    if (!hasMealToday) {
      // If no meal today, start checking from yesterday
      currentDateKey = this.getKeyForDaysAgo(1, timeZoneToUse);
    }

    // Count consecutive days with meals
    for (let daysAgo = 0; daysAgo < 365; daysAgo++) {
      const dateKey = this.getKeyForDaysAgo(daysAgo, timeZoneToUse);
      const hasMealOnDate = meals.some(meal => 
        meal.mealTime && this.getDateKeyInTimeZone(meal.mealTime, timeZoneToUse) === dateKey
      );

      if (hasMealOnDate) {
        streak++;
      } else {
        break;
      }
    }

    // Find the most recent meal date
    const lastMeal = meals.find(meal => meal.mealTime);
    const lastMealDate = lastMeal ? 
      this.getDateKeyInTimeZone(lastMeal.mealTime, timeZoneToUse) : null;

    return { streak, lastMealDate };
  }

  /**
   * Validate CreateMealDto data
   * @param dto - The DTO to validate
   * @throws BadRequestException if validation fails
   */
  private validateCreateMealDto(dto: CreateMealDto): void {
    if (!dto.name || dto.name.trim().length === 0) {
      throw new BadRequestException('Meal name is required and cannot be empty');
    }
    
    if (!dto.description || dto.description.trim().length === 0) {
      throw new BadRequestException('Meal description is required and cannot be empty');
    }
    
    if (!dto.mealTime) {
      throw new BadRequestException('Meal time is required');
    }
    
    if (!dto.userId || dto.userId.trim().length === 0) {
      throw new BadRequestException('User ID is required');
    }
    
    if (dto.totalCalories !== undefined && dto.totalCalories < 0) {
      throw new BadRequestException('Total calories cannot be negative');
    }
    
    // Validate date format
    const mealTime = new Date(dto.mealTime);
    if (isNaN(mealTime.getTime())) {
      throw new BadRequestException('Invalid meal time format');
    }
  }

  /**
   * Validate UpdateMealDto data
   * @param dto - The DTO to validate
   * @throws BadRequestException if validation fails
   */
  private validateUpdateMealDto(dto: UpdateMealDto): void {
    if (dto.name !== undefined && (!dto.name || dto.name.trim().length === 0)) {
      throw new BadRequestException('Meal name cannot be empty');
    }
    
    if (dto.description !== undefined && (!dto.description || dto.description.trim().length === 0)) {
      throw new BadRequestException('Meal description cannot be empty');
    }
    
    if (dto.mealTime !== undefined) {
      const mealTime = new Date(dto.mealTime);
      if (isNaN(mealTime.getTime())) {
        throw new BadRequestException('Invalid meal time format');
      }
    }
    
    if (dto.totalCalories !== undefined && dto.totalCalories < 0) {
      throw new BadRequestException('Total calories cannot be negative');
    }
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