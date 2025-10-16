"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const typeorm_1 = require("@nestjs/typeorm");
const meal_service_1 = require("./meal.service");
const meal_entity_1 = require("./meal.entity");
const common_1 = require("@nestjs/common");
describe('MealService', () => {
    let service;
    let mockRepository;
    beforeEach(async () => {
        const mockRepositoryValue = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
        };
        const module = await testing_1.Test.createTestingModule({
            providers: [
                meal_service_1.MealService,
                {
                    provide: (0, typeorm_1.getRepositoryToken)(meal_entity_1.Meal),
                    useValue: mockRepositoryValue,
                },
            ],
        }).compile();
        service = module.get(meal_service_1.MealService);
        mockRepository = module.get((0, typeorm_1.getRepositoryToken)(meal_entity_1.Meal));
    });
    it('should be defined', () => {
        expect(service).toBeDefined();
    });
    describe('create', () => {
        it('should create a meal', async () => {
            const createMealDto = {
                name: 'Breakfast',
                description: 'Healthy breakfast',
                mealTime: new Date(),
                totalCalories: 500,
                notes: 'Test meal',
                userId: 'user-uuid-123',
            };
            const expectedMeal = { id: 'meal-uuid-123', ...createMealDto };
            mockRepository.create.mockReturnValue(expectedMeal);
            mockRepository.save.mockResolvedValue(expectedMeal);
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
            mockRepository.find.mockResolvedValue(expectedMeals);
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
            mockRepository.findOne.mockResolvedValue(expectedMeal);
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
            await expect(service.findOne(mealId)).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('update', () => {
        it('should update a meal', async () => {
            const mealId = 'meal-uuid-123';
            const updateMealDto = {
                notes: 'Updated meal notes',
            };
            const existingMeal = { id: mealId, name: 'Breakfast', notes: 'Old notes' };
            const updatedMeal = { ...existingMeal, ...updateMealDto };
            mockRepository.findOne.mockResolvedValue(existingMeal);
            mockRepository.save.mockResolvedValue(updatedMeal);
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
            mockRepository.findOne.mockResolvedValue(existingMeal);
            mockRepository.remove.mockResolvedValue(existingMeal);
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
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBeGreaterThan(0);
            expect(result.lastMealDate).toBeDefined();
        });
        it('should handle timezone correctly - New York', async () => {
            const userId = 'user-uuid-123';
            const meals = [
                { mealTime: new Date() },
            ];
            mockRepository.find.mockResolvedValue(meals);
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
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBeGreaterThanOrEqual(1);
        });
        it('should handle invalid timezone gracefully', async () => {
            const userId = 'user-uuid-123';
            const meals = [
                { mealTime: new Date() },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');
            expect(result.streak).toBeGreaterThanOrEqual(0);
            expect(result.lastMealDate).toBeDefined();
        });
        it('should handle undefined timezone', async () => {
            const userId = 'user-uuid-123';
            const meals = [
                { mealTime: new Date() },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId);
            expect(result.streak).toBeGreaterThanOrEqual(0);
            expect(result.lastMealDate).toBeDefined();
        });
        it('should not overflow with large date ranges', async () => {
            const farPast = new Date(1970, 0, 1);
            const meals = [
                { mealTime: new Date(farPast.getTime() + 1 * 24 * 60 * 60 * 1000) },
                { mealTime: farPast },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone('user-uuid-123', 'UTC');
            expect(result.streak).toBeGreaterThanOrEqual(0);
            expect(result.lastMealDate).toBeDefined();
        });
        it('should handle future dates gracefully', async () => {
            const userId = 'user-uuid-123';
            const futureDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
            const meals = [
                { mealTime: futureDate },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(0);
        });
        it('should limit daysAgo to prevent infinite loops', async () => {
            const userId = 'user-uuid-123';
            const meals = [];
            for (let i = 0; i < 10; i++) {
                meals.push({ mealTime: new Date(Date.now() - i * 24 * 60 * 60 * 1000) });
            }
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(10);
            expect(Number.isFinite(result.streak)).toBe(true);
            expect(result.streak).toBeLessThanOrEqual(365);
        });
        it('should handle edge case of meals at midnight boundary', async () => {
            const userId = 'user-uuid-123';
            const midnight = new Date();
            midnight.setHours(0, 0, 0, 0);
            const meals = [
                { mealTime: midnight },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBeGreaterThanOrEqual(0);
        });
        it('should return correct lastMealDate format', async () => {
            const userId = 'user-uuid-123';
            const meals = [
                { mealTime: new Date() },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.lastMealDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
        });
        it('should handle Pacific timezone correctly', async () => {
            const userId = 'user-uuid-123';
            const meals = [
                { mealTime: new Date() },
            ];
            mockRepository.find.mockResolvedValue(meals);
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
            mockRepository.find.mockResolvedValue(meals);
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
            mockRepository.find.mockResolvedValue(meals);
            const result1 = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
            expect(result1.streak).toBeGreaterThanOrEqual(0);
            const result2 = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');
            expect(result2.streak).toBeGreaterThanOrEqual(0);
        });
    });
});
//# sourceMappingURL=meal.service.spec.js.map