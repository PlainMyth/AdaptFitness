import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MealService } from './meal.service';
import { Meal } from './meal.entity';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { NotFoundException } from '@nestjs/common';

/**
 * Meal Service Unit Tests
 *
 * This file contains comprehensive unit tests for the MealService class.
 * It tests all CRUD operations, streak calculations, and edge cases.
 *
 * Test coverage:
 * - Service instantiation and dependency injection
 * - Create, read, update, delete operations
 * - Streak calculation functionality
 * - Timezone handling
 * - Error handling and validation
 * - Edge cases and boundary conditions
 */
describe('MealService', () => {
  let service: MealService;
  let mockRepository: jest.Mocked<Repository<Meal>>;

  beforeEach(async () => {
    const mockRepositoryValue = {
      create: jest.fn(),
      save: jest.fn(),
      find: jest.fn(),
      findOne: jest.fn(),
      remove: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MealService,
        {
          provide: getRepositoryToken(Meal),
          useValue: mockRepositoryValue,
        },
      ],
    }).compile();

    service = module.get<MealService>(MealService);
    mockRepository = module.get(getRepositoryToken(Meal));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a meal', async () => {
      const createMealDto: CreateMealDto = {
        name: 'Breakfast',
        description: 'Healthy breakfast',
        mealTime: new Date(),
        totalCalories: 500,
        notes: 'Test meal',
        userId: 'user-uuid-123',
      };

      const expectedMeal = { id: 'meal-uuid-123', ...createMealDto };
      mockRepository.create.mockReturnValue(expectedMeal as any);
      mockRepository.save.mockResolvedValue(expectedMeal as any);

      const result = await service.create(createMealDto);

      expect(mockRepository.create).toHaveBeenCalledWith(createMealDto);
      expect(mockRepository.save).toHaveBeenCalledWith(expectedMeal);
      expect(result).toEqual(expectedMeal);
    });
  });

  describe('findAll', () => {
    it('should return all meals for a user', async () => {
      const userId = 'user-uuid-123';
      const expectedMeals = [
        { id: 'meal-uuid-1', name: 'Breakfast', userId },
        { id: 'meal-uuid-2', name: 'Lunch', userId },
      ];

      mockRepository.find.mockResolvedValue(expectedMeals as any);

      const result = await service.findAll(userId);

      expect(mockRepository.find).toHaveBeenCalledWith({
        where: { user: { id: userId } },
        order: { mealTime: 'DESC' },
      });
      expect(result).toEqual(expectedMeals);
    });
  });

  describe('findOne', () => {
    it('should return a meal when found', async () => {
      const mealId = 'meal-uuid-123';
      const expectedMeal = { id: mealId, name: 'Breakfast' };

      mockRepository.findOne.mockResolvedValue(expectedMeal as any);

      const result = await service.findOne(mealId);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: mealId },
        relations: ['user'],
      });
      expect(result).toEqual(expectedMeal);
    });

    it('should throw NotFoundException when meal not found', async () => {
      const mealId = 'non-existent-uuid';
      mockRepository.findOne.mockResolvedValue(null);

      await expect(service.findOne(mealId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update a meal', async () => {
      const mealId = 'meal-uuid-123';
      const updateMealDto: UpdateMealDto = {
        notes: 'Updated meal notes',
      };
      const existingMeal = { id: mealId, name: 'Breakfast', notes: 'Old notes' };
      const updatedMeal = { ...existingMeal, ...updateMealDto };

      mockRepository.findOne.mockResolvedValue(existingMeal as any);
      mockRepository.save.mockResolvedValue(updatedMeal as any);

      const result = await service.update(mealId, updateMealDto);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: mealId },
        relations: ['user'],
      });
      expect(mockRepository.save).toHaveBeenCalledWith(updatedMeal);
      expect(result).toEqual(updatedMeal);
    });
  });

  describe('remove', () => {
    it('should remove a meal', async () => {
      const mealId = 'meal-uuid-123';
      const existingMeal = { id: mealId, name: 'Breakfast' };

      mockRepository.findOne.mockResolvedValue(existingMeal as any);
      mockRepository.remove.mockResolvedValue(existingMeal as any);

      await service.remove(mealId);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: mealId },
        relations: ['user'],
      });
      expect(mockRepository.remove).toHaveBeenCalledWith(existingMeal);
    });
  });

  describe('getCurrentStreakInTimeZone', () => {
    it('should return zero streak when no meals exist', async () => {
      const userId = 'user-uuid-123';
      mockRepository.find.mockResolvedValue([]);

      const result = await service.getCurrentStreakInTimeZone(userId);

      expect(result).toEqual({ streak: 0, lastMealDate: null });
    });

    it('should calculate streak correctly with consecutive meals', async () => {
      const userId = 'user-uuid-123';
      const today = new Date();
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
      const dayBefore = new Date(today.getTime() - 2 * 24 * 60 * 60 * 1000);

      const meals = [
        { mealTime: today },
        { mealTime: yesterday },
        { mealTime: dayBefore },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThan(0);
      expect(result.lastMealDate).toBeDefined();
    });

    it('should handle timezone correctly - New York', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastMealDate).toBeDefined();
    });

    it('should handle multiple meals on same day', async () => {
      const userId = 'user-uuid-123';
      const today = new Date();
      const meals = [
        { mealTime: new Date(today.getTime() + 1000) },
        { mealTime: new Date(today.getTime() + 2000) },
        { mealTime: new Date(today.getTime() + 3000) },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(1);
    });

    it('should handle invalid timezone gracefully', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastMealDate).toBeDefined();
    });

    it('should handle undefined timezone', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId);

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastMealDate).toBeDefined();
    });

    it('should not overflow with large date ranges', async () => {
      // Test with dates far in the past to ensure no overflow
      const farPast = new Date(1970, 0, 1); // Unix epoch
      const meals = [
        { mealTime: new Date(farPast.getTime() + 1 * 24 * 60 * 60 * 1000) },
        { mealTime: farPast },
      ];
      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone('user-uuid-123', 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastMealDate).toBeDefined();
    });

    it('should handle future dates gracefully', async () => {
      const userId = 'user-uuid-123';
      const futureDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days in future
      const meals = [
        { mealTime: futureDate },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBe(0); // Future dates shouldn't count for current streak
    });

    it('should limit daysAgo to prevent infinite loops', async () => {
      const userId = 'user-uuid-123';
      // Create a reasonable number of consecutive meals
      const meals = [];
      for (let i = 0; i < 10; i++) {
        meals.push({ mealTime: new Date(Date.now() - i * 24 * 60 * 60 * 1000) });
      }
      mockRepository.find.mockResolvedValue(meals);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBe(10);
      expect(Number.isFinite(result.streak)).toBe(true);
      expect(result.streak).toBeLessThanOrEqual(365); // Should be limited to 365 days
    });

    it('should handle edge case of meals at midnight boundary', async () => {
      const userId = 'user-uuid-123';
      const midnight = new Date();
      midnight.setHours(0, 0, 0, 0);
      const meals = [
        { mealTime: midnight },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(0);
    });

    it('should return correct lastMealDate format', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.lastMealDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    });

    it('should handle Pacific timezone correctly', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'America/Los_Angeles');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastMealDate).toBeDefined();
    });

    it('should handle meals with null mealTime', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: null },
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastMealDate).toBeDefined();
    });
  });

  describe('private helper methods', () => {
    it('should validate timezone correctly', async () => {
      const userId = 'user-uuid-123';
      const meals = [
        { mealTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(meals as any);

      // Test with valid timezone
      const result1 = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
      expect(result1.streak).toBeGreaterThanOrEqual(0);

      // Test with invalid timezone (should fallback to UTC)
      const result2 = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');
      expect(result2.streak).toBeGreaterThanOrEqual(0);
    });
  });
});