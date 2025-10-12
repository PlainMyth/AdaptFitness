"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const typeorm_1 = require("@nestjs/typeorm");
const meal_service_1 = require("./meal.service");
const meal_entity_1 = require("./meal.entity");
describe('MealService', () => {
    let service;
    let repository;
    const mockRepository = {
        create: jest.fn(),
        save: jest.fn(),
        find: jest.fn(),
        findOne: jest.fn(),
        delete: jest.fn(),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [
                meal_service_1.MealService,
                {
                    provide: (0, typeorm_1.getRepositoryToken)(meal_entity_1.Meal),
                    useValue: mockRepository,
                },
            ],
        }).compile();
        service = module.get(meal_service_1.MealService);
        repository = module.get((0, typeorm_1.getRepositoryToken)(meal_entity_1.Meal));
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    describe('getCurrentStreakInTimeZone', () => {
        const userId = 'test-user-id';
        it('should return streak 0 when no meals exist', async () => {
            mockRepository.find.mockResolvedValue([]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
            expect(result).toEqual({ streak: 0 });
            expect(mockRepository.find).toHaveBeenCalledWith({
                where: { userId },
                select: ['mealTime'],
                order: { mealTime: 'DESC' },
            });
        });
        it('should return streak 1 for meal today', async () => {
            const today = new Date();
            const todayMeal = { mealTime: today };
            mockRepository.find.mockResolvedValue([todayMeal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
            expect(result.lastMealDate).toBeDefined();
        });
        it('should return streak 1 for meal yesterday only', async () => {
            const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
            const yesterdayMeal = { mealTime: yesterday };
            mockRepository.find.mockResolvedValue([yesterdayMeal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
            expect(result.lastMealDate).toBeDefined();
        });
        it('should return streak 0 for meal more than 2 days ago', async () => {
            const threeDaysAgo = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000);
            const oldMeal = { mealTime: threeDaysAgo };
            mockRepository.find.mockResolvedValue([oldMeal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(0);
        });
        it('should calculate consecutive streak correctly', async () => {
            const now = Date.now();
            const meals = [
                { mealTime: new Date(now - 0 * 24 * 60 * 60 * 1000) },
                { mealTime: new Date(now - 1 * 24 * 60 * 60 * 1000) },
                { mealTime: new Date(now - 2 * 24 * 60 * 60 * 1000) },
                { mealTime: new Date(now - 5 * 24 * 60 * 60 * 1000) },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(3);
        });
        it('should handle timezone correctly - New York', async () => {
            const nyMeal = { mealTime: new Date('2024-01-15T20:00:00Z') };
            mockRepository.find.mockResolvedValue([nyMeal]);
            const originalDate = Date;
            global.Date = jest.fn(() => new originalDate('2024-01-16T02:00:00Z'));
            global.Date.now = jest.fn(() => new originalDate('2024-01-16T02:00:00Z').getTime());
            const result = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
            expect(result.streak).toBe(1);
            global.Date = originalDate;
        });
        it('should handle multiple meals on same day', async () => {
            const sameDay = new Date();
            const meals = [
                { mealTime: new Date(sameDay.getTime() + 1000) },
                { mealTime: sameDay },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
        });
        it('should handle invalid timezone gracefully', async () => {
            const today = new Date();
            const meal = { mealTime: today };
            mockRepository.find.mockResolvedValue([meal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');
            expect(result.streak).toBe(1);
        });
        it('should handle undefined timezone', async () => {
            const today = new Date();
            const meal = { mealTime: today };
            mockRepository.find.mockResolvedValue([meal]);
            const result = await service.getCurrentStreakInTimeZone(userId, undefined);
            expect(result.streak).toBe(1);
        });
        it('should not overflow with large date ranges', async () => {
            const farPast = new Date(1970, 0, 1);
            const meals = [
                { mealTime: new Date(farPast.getTime() + 1 * 24 * 60 * 60 * 1000) },
                { mealTime: farPast },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(2);
            expect(Number.isFinite(result.streak)).toBe(true);
            expect(Number.isNaN(result.streak)).toBe(false);
        });
        it('should handle future dates gracefully', async () => {
            const future = new Date(Date.now() + 24 * 60 * 60 * 1000);
            const meal = { mealTime: future };
            mockRepository.find.mockResolvedValue([meal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(0);
        });
        it('should limit daysAgo to prevent infinite loops', async () => {
            const meals = [];
            for (let i = 0; i < 10; i++) {
                meals.push({ mealTime: new Date(Date.now() - i * 24 * 60 * 60 * 1000) });
            }
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(10);
            expect(Number.isFinite(result.streak)).toBe(true);
        });
        it('should handle edge case of meals at midnight boundary', async () => {
            const midnightUTC = new Date('2024-01-15T00:00:00Z');
            const meals = [
                { mealTime: new Date(midnightUTC.getTime() + 1000) },
                { mealTime: midnightUTC },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
        });
        it('should return correct lastMealDate format', async () => {
            const specificDate = new Date('2024-01-15T12:00:00Z');
            const meal = { mealTime: specificDate };
            mockRepository.find.mockResolvedValue([meal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.lastMealDate).toBe('2024-01-15');
            expect(typeof result.lastMealDate).toBe('string');
        });
        it('should handle Pacific timezone correctly', async () => {
            const pstMeal = { mealTime: new Date('2024-01-15T08:00:00Z') };
            mockRepository.find.mockResolvedValue([pstMeal]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'America/Los_Angeles');
            expect(result.streak).toBe(1);
            expect(result.lastMealDate).toBe('2024-01-14');
        });
        it('should handle meals with null mealTime', async () => {
            const meals = [
                { mealTime: new Date() },
                { mealTime: null },
                { mealTime: undefined },
            ];
            mockRepository.find.mockResolvedValue(meals);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
        });
    });
    describe('private helper methods', () => {
        it('should validate timezone correctly', async () => {
            const meal = { mealTime: new Date() };
            mockRepository.find.mockResolvedValue([meal]);
            await service.getCurrentStreakInTimeZone('user', 'America/New_York');
            await service.getCurrentStreakInTimeZone('user', 'Invalid/Zone');
            await service.getCurrentStreakInTimeZone('user', undefined);
            expect(mockRepository.find).toHaveBeenCalledTimes(3);
        });
    });
    describe('getCurrentStreak', () => {
        it('should call getCurrentStreakInTimeZone without timezone', async () => {
            const spy = jest.spyOn(service, 'getCurrentStreakInTimeZone').mockResolvedValue({ streak: 5 });
            await service.getCurrentStreak('user-id');
            expect(spy).toHaveBeenCalledWith('user-id');
        });
    });
});
//# sourceMappingURL=meal.service.spec.js.map