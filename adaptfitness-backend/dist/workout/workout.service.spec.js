"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const typeorm_1 = require("@nestjs/typeorm");
const workout_service_1 = require("./workout.service");
const workout_entity_1 = require("./workout.entity");
describe('WorkoutService', () => {
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
                workout_service_1.WorkoutService,
                {
                    provide: (0, typeorm_1.getRepositoryToken)(workout_entity_1.Workout),
                    useValue: mockRepository,
                },
            ],
        }).compile();
        service = module.get(workout_service_1.WorkoutService);
        repository = module.get((0, typeorm_1.getRepositoryToken)(workout_entity_1.Workout));
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    describe('getCurrentStreakInTimeZone', () => {
        const userId = 'test-user-id';
        it('should return streak 0 when no workouts exist', async () => {
            mockRepository.find.mockResolvedValue([]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
            expect(result).toEqual({ streak: 0 });
            expect(mockRepository.find).toHaveBeenCalledWith({
                where: { userId },
                select: ['startTime'],
                order: { startTime: 'DESC' },
            });
        });
        it('should return streak 1 for workout today', async () => {
            const today = new Date();
            const todayWorkout = { startTime: today };
            mockRepository.find.mockResolvedValue([todayWorkout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
            expect(result.lastWorkoutDate).toBeDefined();
        });
        it('should return streak 1 for workout yesterday only', async () => {
            const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
            const yesterdayWorkout = { startTime: yesterday };
            mockRepository.find.mockResolvedValue([yesterdayWorkout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
            expect(result.lastWorkoutDate).toBeDefined();
        });
        it('should return streak 0 for workout more than 2 days ago', async () => {
            const threeDaysAgo = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000);
            const oldWorkout = { startTime: threeDaysAgo };
            mockRepository.find.mockResolvedValue([oldWorkout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(0);
        });
        it('should calculate consecutive streak correctly', async () => {
            const now = Date.now();
            const workouts = [
                { startTime: new Date(now - 0 * 24 * 60 * 60 * 1000) },
                { startTime: new Date(now - 1 * 24 * 60 * 60 * 1000) },
                { startTime: new Date(now - 2 * 24 * 60 * 60 * 1000) },
                { startTime: new Date(now - 5 * 24 * 60 * 60 * 1000) },
            ];
            mockRepository.find.mockResolvedValue(workouts);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(3);
        });
        it('should handle timezone correctly - New York', async () => {
            const nyWorkout = { startTime: new Date('2024-01-15T20:00:00Z') };
            mockRepository.find.mockResolvedValue([nyWorkout]);
            const originalDate = Date;
            global.Date = jest.fn(() => new originalDate('2024-01-16T02:00:00Z'));
            global.Date.now = jest.fn(() => new originalDate('2024-01-16T02:00:00Z').getTime());
            const result = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
            expect(result.streak).toBe(1);
            global.Date = originalDate;
        });
        it('should handle multiple workouts on same day', async () => {
            const sameDay = new Date();
            const workouts = [
                { startTime: new Date(sameDay.getTime() + 1000) },
                { startTime: sameDay },
            ];
            mockRepository.find.mockResolvedValue(workouts);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
        });
        it('should handle invalid timezone gracefully', async () => {
            const today = new Date();
            const workout = { startTime: today };
            mockRepository.find.mockResolvedValue([workout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');
            expect(result.streak).toBe(1);
        });
        it('should handle undefined timezone', async () => {
            const today = new Date();
            const workout = { startTime: today };
            mockRepository.find.mockResolvedValue([workout]);
            const result = await service.getCurrentStreakInTimeZone(userId, undefined);
            expect(result.streak).toBe(1);
        });
        it('should not overflow with large date ranges', async () => {
            const farPast = new Date(1970, 0, 1);
            const workouts = [
                { startTime: new Date(farPast.getTime() + 1 * 24 * 60 * 60 * 1000) },
                { startTime: farPast },
            ];
            mockRepository.find.mockResolvedValue(workouts);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(2);
            expect(Number.isFinite(result.streak)).toBe(true);
            expect(Number.isNaN(result.streak)).toBe(false);
        });
        it('should handle future dates gracefully', async () => {
            const future = new Date(Date.now() + 24 * 60 * 60 * 1000);
            const workout = { startTime: future };
            mockRepository.find.mockResolvedValue([workout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(0);
        });
        it('should limit daysAgo to prevent infinite loops', async () => {
            const workouts = [];
            for (let i = 0; i < 10; i++) {
                workouts.push({ startTime: new Date(Date.now() - i * 24 * 60 * 60 * 1000) });
            }
            mockRepository.find.mockResolvedValue(workouts);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(10);
            expect(Number.isFinite(result.streak)).toBe(true);
        });
        it('should handle edge case of workouts at midnight boundary', async () => {
            const midnightUTC = new Date('2024-01-15T00:00:00Z');
            const workouts = [
                { startTime: new Date(midnightUTC.getTime() + 1000) },
                { startTime: midnightUTC },
            ];
            mockRepository.find.mockResolvedValue(workouts);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(1);
        });
        it('should return correct lastWorkoutDate format', async () => {
            const specificDate = new Date('2024-01-15T12:00:00Z');
            const workout = { startTime: specificDate };
            mockRepository.find.mockResolvedValue([workout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.lastWorkoutDate).toBe('2024-01-15');
            expect(typeof result.lastWorkoutDate).toBe('string');
        });
        it('should handle Pacific timezone correctly', async () => {
            const pstWorkout = { startTime: new Date('2024-01-15T08:00:00Z') };
            mockRepository.find.mockResolvedValue([pstWorkout]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'America/Los_Angeles');
            expect(result.streak).toBe(1);
            expect(result.lastWorkoutDate).toBe('2024-01-14');
        });
    });
    describe('private helper methods', () => {
        it('should validate timezone correctly', async () => {
            const workout = { startTime: new Date() };
            mockRepository.find.mockResolvedValue([workout]);
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
//# sourceMappingURL=workout.service.spec.js.map