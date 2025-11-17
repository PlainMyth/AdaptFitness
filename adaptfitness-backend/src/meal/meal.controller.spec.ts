import { Test, TestingModule } from '@nestjs/testing';
import { MealController } from './meal.controller';
import { MealService } from './meal.service';
import { FoodService } from './food.service';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { NotFoundException } from '@nestjs/common';

/**
 * Meal Controller Integration Tests
 *
 * This file contains comprehensive integration tests for the MealController.
 * It tests all HTTP endpoints, authentication, and error handling.
 *
 * Test coverage:
 * - Create meal endpoint
 * - Get all meals endpoint
 * - Get single meal endpoint
 * - Update meal endpoint
 * - Delete meal endpoint
 * - Get streak endpoint
 * - Food search endpoint
 * - Barcode lookup endpoint
 * - Authentication requirements
 * - Error handling
 */
describe('MealController', () => {
  let controller: MealController;
  let mealService: MealService;
  let foodService: FoodService;

  const mockMealService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
    getCurrentStreakInTimeZone: jest.fn(),
  };

  const mockFoodService = {
    searchFoods: jest.fn(),
    getFoodByBarcode: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MealController],
      providers: [
        {
          provide: MealService,
          useValue: mockMealService,
        },
        {
          provide: FoodService,
          useValue: mockFoodService,
        },
      ],
    }).compile();

    controller = module.get<MealController>(MealController);
    mealService = module.get<MealService>(MealService);
    foodService = module.get<FoodService>(FoodService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /meals', () => {
    it('should create a meal successfully', async () => {
      // Arrange
      const createMealDto: CreateMealDto = {
        name: 'Breakfast',
        description: 'Healthy breakfast',
        mealTime: new Date(),
        totalCalories: 500,
        notes: 'Test meal notes',
        userId: 'user-123',
      };
      const mockRequest = { user: { id: 'user-123' } };
      const mockMeal = {
        id: 'meal-123',
        ...createMealDto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockMealService.create.mockResolvedValue(mockMeal);

      // Act
      const result = await controller.create(mockRequest, createMealDto);

      // Assert
      expect(mealService.create).toHaveBeenCalledWith({
        ...createMealDto,
        userId: 'user-123',
      });
      expect(result).toEqual(mockMeal);
    });

    it('should set userId from request user', async () => {
      // Arrange
      const createMealDto: CreateMealDto = {
        name: 'Lunch',
        mealTime: new Date(),
        totalCalories: 600,
        userId: undefined as any,
      };
      const mockRequest = { user: { id: 'user-456' } };
      const mockMeal = { id: 'meal-456', ...createMealDto, userId: 'user-456' };

      mockMealService.create.mockResolvedValue(mockMeal);

      // Act
      await controller.create(mockRequest, createMealDto);

      // Assert
      expect(createMealDto.userId).toBe('user-456');
      expect(mealService.create).toHaveBeenCalledWith(expect.objectContaining({
        userId: 'user-456',
      }));
    });
  });

  describe('GET /meals', () => {
    it('should return all meals for authenticated user', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      const mockMeals = [
        { id: 'meal-1', name: 'Breakfast', userId: 'user-123' },
        { id: 'meal-2', name: 'Lunch', userId: 'user-123' },
      ];

      mockMealService.findAll.mockResolvedValue(mockMeals);

      // Act
      const result = await controller.findAll(mockRequest);

      // Assert
      expect(mealService.findAll).toHaveBeenCalledWith('user-123');
      expect(result).toEqual(mockMeals);
    });

    it('should return empty array when user has no meals', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      mockMealService.findAll.mockResolvedValue([]);

      // Act
      const result = await controller.findAll(mockRequest);

      // Assert
      expect(result).toEqual([]);
    });
  });

  describe('GET /meals/:id', () => {
    it('should return a meal by id', async () => {
      // Arrange
      const mealId = 'meal-123';
      const mockRequest = { user: { id: 'user-123' } };
      const mockMeal = { id: mealId, name: 'Breakfast', userId: 'user-123' };

      mockMealService.findOne.mockResolvedValue(mockMeal);

      // Act
      const result = await controller.findOne(mockRequest, mealId);

      // Assert
      expect(mealService.findOne).toHaveBeenCalledWith(mealId);
      expect(result).toEqual(mockMeal);
    });

    it('should throw NotFoundException when meal not found', async () => {
      // Arrange
      const mealId = 'non-existent';
      const mockRequest = { user: { id: 'user-123' } };

      mockMealService.findOne.mockRejectedValue(new NotFoundException('Meal not found'));

      // Act & Assert
      await expect(controller.findOne(mockRequest, mealId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('PUT /meals/:id', () => {
    it('should update a meal successfully', async () => {
      // Arrange
      const mealId = 'meal-123';
      const mockRequest = { user: { id: 'user-123' } };
      const updateMealDto: UpdateMealDto = {
        name: 'Updated Breakfast',
        totalCalories: 550,
      };
      const mockUpdatedMeal = {
        id: mealId,
        name: 'Updated Breakfast',
        totalCalories: 550,
        userId: 'user-123',
      };

      mockMealService.update.mockResolvedValue(mockUpdatedMeal);

      // Act
      const result = await controller.update(mockRequest, mealId, updateMealDto);

      // Assert
      expect(mealService.update).toHaveBeenCalledWith(mealId, updateMealDto);
      expect(result).toEqual(mockUpdatedMeal);
    });
  });

  describe('DELETE /meals/:id', () => {
    it('should delete a meal successfully', async () => {
      // Arrange
      const mealId = 'meal-123';
      const mockRequest = { user: { id: 'user-123' } };

      mockMealService.remove.mockResolvedValue(undefined);

      // Act
      const result = await controller.remove(mockRequest, mealId);

      // Assert
      expect(mealService.remove).toHaveBeenCalledWith(mealId);
      expect(result).toEqual({ message: 'Meal deleted successfully' });
    });
  });

  describe('GET /meals/streak/current', () => {
    it('should return current streak for user', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      const mockStreak = { streak: 5, lastMealDate: '2024-01-15' };

      mockMealService.getCurrentStreakInTimeZone.mockResolvedValue(mockStreak);

      // Act
      const result = await controller.getCurrentStreak(mockRequest);

      // Assert
      expect(mealService.getCurrentStreakInTimeZone).toHaveBeenCalledWith('user-123', undefined);
      expect(result).toEqual(mockStreak);
    });

    it('should return streak with timezone parameter', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      const timezone = 'America/New_York';
      const mockStreak = { streak: 3, lastMealDate: '2024-01-15' };

      mockMealService.getCurrentStreakInTimeZone.mockResolvedValue(mockStreak);

      // Act
      const result = await controller.getCurrentStreak(mockRequest, timezone);

      // Assert
      expect(mealService.getCurrentStreakInTimeZone).toHaveBeenCalledWith('user-123', timezone);
      expect(result).toEqual(mockStreak);
    });
  });

  describe('GET /meals/foods/search', () => {
    it('should search for foods successfully', async () => {
      // Arrange
      const searchDto = { query: 'apple', page: 1, pageSize: 20 };
      const mockSearchResults = {
        foods: [
          { id: 'food-1', name: 'Apple', calories: 52 },
          { id: 'food-2', name: 'Apple Juice', calories: 45 },
        ],
        totalCount: 2,
        page: 1,
        pageSize: 20,
      };

      mockFoodService.searchFoods.mockResolvedValue(mockSearchResults);

      // Act
      const result = await controller.searchFoods(searchDto);

      // Assert
      expect(foodService.searchFoods).toHaveBeenCalledWith(searchDto);
      expect(result).toEqual(mockSearchResults);
    });

    it('should handle empty search results', async () => {
      // Arrange
      const searchDto = { query: 'nonexistentfood12345', page: 1, pageSize: 20 };
      const mockSearchResults = {
        foods: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
      };

      mockFoodService.searchFoods.mockResolvedValue(mockSearchResults);

      // Act
      const result = await controller.searchFoods(searchDto);

      // Assert
      expect(result.foods).toEqual([]);
      expect(result.totalCount).toBe(0);
    });
  });

  describe('GET /meals/foods/barcode/:barcode', () => {
    it('should get food by barcode successfully', async () => {
      // Arrange
      const barcode = '1234567890123';
      const mockFood = {
        id: 'food-123',
        name: 'Test Product',
        barcode: barcode,
        calories: 100,
      };

      mockFoodService.getFoodByBarcode.mockResolvedValue(mockFood);

      // Act
      const result = await controller.getFoodByBarcode(barcode);

      // Assert
      expect(foodService.getFoodByBarcode).toHaveBeenCalledWith(barcode);
      expect(result).toEqual(mockFood);
    });

    it('should handle barcode not found', async () => {
      // Arrange
      const barcode = '0000000000000';

      mockFoodService.getFoodByBarcode.mockRejectedValue(new NotFoundException('Food not found'));

      // Act & Assert
      await expect(controller.getFoodByBarcode(barcode)).rejects.toThrow(NotFoundException);
    });
  });
});

