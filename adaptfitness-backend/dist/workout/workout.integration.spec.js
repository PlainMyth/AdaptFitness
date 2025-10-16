"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const workout_controller_1 = require("./workout.controller");
const workout_service_1 = require("./workout.service");
const workout_entity_1 = require("./workout.entity");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
describe('Workout Integration Tests', () => {
    let app;
    let service;
    let mockRepository;
    const mockUser = {
        id: 'user-uuid-123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
    };
    beforeEach(async () => {
        const mockRepositoryValue = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
        };
        const mockJwtAuthGuard = {
            canActivate: jest.fn().mockReturnValue(true),
        };
        const module = await testing_1.Test.createTestingModule({
            controllers: [workout_controller_1.WorkoutController],
            providers: [
                workout_service_1.WorkoutService,
                {
                    provide: (0, typeorm_1.getRepositoryToken)(workout_entity_1.Workout),
                    useValue: mockRepositoryValue,
                },
            ],
        })
            .overrideGuard(jwt_auth_guard_1.JwtAuthGuard)
            .useValue(mockJwtAuthGuard)
            .compile();
        app = module.createNestApplication();
        app.useGlobalPipes(new common_1.ValidationPipe({
            whitelist: true,
            transform: true,
        }));
        await app.init();
        service = module.get(workout_service_1.WorkoutService);
        mockRepository = module.get((0, typeorm_1.getRepositoryToken)(workout_entity_1.Workout));
    });
    afterEach(async () => {
        await app.close();
    });
    describe('Complete Workout CRUD Flow', () => {
        it('should create, retrieve, update, and delete a workout', async () => {
            const createDto = {
                name: 'Morning Run',
                description: 'Test workout',
                startTime: new Date(),
                userId: mockUser.id,
            };
            const createdWorkout = {
                id: 'workout-uuid-123',
                ...createDto,
                totalCaloriesBurned: 0,
                totalDuration: 0,
            };
            mockRepository.create.mockReturnValue(createdWorkout);
            mockRepository.save.mockResolvedValue(createdWorkout);
            const createResult = await service.create(createDto);
            expect(createResult.id).toBe('workout-uuid-123');
            expect(createResult.name).toBe('Morning Run');
            mockRepository.findOne.mockResolvedValue(createdWorkout);
            const foundWorkout = await service.findOne('workout-uuid-123');
            expect(foundWorkout.id).toBe('workout-uuid-123');
            expect(foundWorkout.name).toBe('Morning Run');
            const updateDto = {
                name: 'Evening Run',
                totalCaloriesBurned: 300,
            };
            const updatedWorkout = {
                ...createdWorkout,
                ...updateDto,
            };
            mockRepository.save.mockResolvedValue(updatedWorkout);
            const updateResult = await service.update('workout-uuid-123', updateDto);
            expect(updateResult.name).toBe('Evening Run');
            expect(updateResult.totalCaloriesBurned).toBe(300);
            mockRepository.remove.mockResolvedValue(updatedWorkout);
            await service.remove('workout-uuid-123');
            expect(mockRepository.remove).toHaveBeenCalled();
        });
    });
    describe('Multi-User Workout Isolation', () => {
        it('should only return workouts for the correct user', async () => {
            const user1Id = 'user-1';
            const user2Id = 'user-2';
            const user1Workouts = [
                { id: 'workout-1', name: 'User 1 Workout', userId: user1Id },
                { id: 'workout-2', name: 'User 1 Another', userId: user1Id },
            ];
            mockRepository.find.mockResolvedValue(user1Workouts);
            const results = await service.findAll(user1Id);
            expect(results).toHaveLength(2);
            expect(mockRepository.find).toHaveBeenCalledWith({
                where: { user: { id: user1Id } },
                order: { startTime: 'DESC' },
            });
        });
    });
    describe('Streak Calculation Integration', () => {
        it('should calculate streak across multiple days', async () => {
            const userId = 'user-uuid-123';
            const today = new Date();
            const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
            const twoDaysAgo = new Date(today.getTime() - 2 * 24 * 60 * 60 * 1000);
            const workouts = [
                {
                    id: '1',
                    name: 'Today',
                    startTime: today,
                    userId,
                },
                {
                    id: '2',
                    name: 'Yesterday',
                    startTime: yesterday,
                    userId,
                },
                {
                    id: '3',
                    name: 'Two Days Ago',
                    startTime: twoDaysAgo,
                    userId,
                },
            ];
            mockRepository.find.mockResolvedValue(workouts);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBeGreaterThan(0);
            expect(result.lastWorkoutDate).toBeDefined();
            expect(result.lastWorkoutDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
        });
        it('should return zero streak for user with no workouts', async () => {
            const userId = 'new-user';
            mockRepository.find.mockResolvedValue([]);
            const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(result.streak).toBe(0);
            expect(result.lastWorkoutDate).toBeNull();
        });
    });
    describe('Workout Creation with Validation', () => {
        it('should create workout and validate all fields', async () => {
            const validWorkout = {
                name: 'Complete Workout',
                description: 'Full body workout',
                startTime: new Date(),
                endTime: new Date(Date.now() + 60 * 60 * 1000),
                totalCaloriesBurned: 500,
                totalDuration: 60,
                totalSets: 12,
                totalReps: 120,
                totalWeight: 5000,
                userId: mockUser.id,
            };
            mockRepository.create.mockReturnValue(validWorkout);
            mockRepository.save.mockResolvedValue({ id: 'new-id', ...validWorkout });
            const result = await service.create(validWorkout);
            expect(result.name).toBe('Complete Workout');
            expect(result.totalCaloriesBurned).toBe(500);
            expect(result.totalDuration).toBe(60);
            expect(mockRepository.create).toHaveBeenCalledWith(validWorkout);
            expect(mockRepository.save).toHaveBeenCalled();
        });
    });
    describe('Error Handling Integration', () => {
        it('should handle database errors gracefully', async () => {
            const createDto = {
                name: 'Test Workout',
                description: 'Test',
                startTime: new Date(),
                userId: mockUser.id,
            };
            mockRepository.create.mockReturnValue(createDto);
            mockRepository.save.mockRejectedValue(new Error('Database connection failed'));
            await expect(service.create(createDto)).rejects.toThrow();
        });
        it('should handle not found errors', async () => {
            mockRepository.findOne.mockResolvedValue(null);
            await expect(service.findOne('non-existent-id')).rejects.toThrow();
        });
    });
    describe('Concurrent Workout Operations', () => {
        it('should handle multiple workouts on same day', async () => {
            const userId = 'user-uuid-123';
            const today = new Date();
            const workouts = [
                { id: '1', name: 'Morning Workout', startTime: new Date(today.setHours(8, 0, 0, 0)), userId },
                { id: '2', name: 'Afternoon Workout', startTime: new Date(today.setHours(14, 0, 0, 0)), userId },
                { id: '3', name: 'Evening Workout', startTime: new Date(today.setHours(20, 0, 0, 0)), userId },
            ];
            mockRepository.find.mockResolvedValue(workouts);
            const allWorkouts = await service.findAll(userId);
            expect(allWorkouts).toHaveLength(3);
            const streak = await service.getCurrentStreakInTimeZone(userId, 'UTC');
            expect(streak.streak).toBeGreaterThanOrEqual(1);
        });
    });
    describe('Workout Update Scenarios', () => {
        it('should partially update workout fields', async () => {
            const existingWorkout = {
                id: 'workout-123',
                name: 'Original Name',
                description: 'Original description',
                totalCaloriesBurned: 100,
                startTime: new Date(),
                userId: mockUser.id,
            };
            mockRepository.findOne.mockResolvedValue(existingWorkout);
            const partialUpdate = {
                name: 'Updated Name',
                totalCaloriesBurned: 200,
            };
            mockRepository.save.mockResolvedValue({
                ...existingWorkout,
                ...partialUpdate,
            });
            const result = await service.update('workout-123', partialUpdate);
            expect(result.name).toBe('Updated Name');
            expect(result.totalCaloriesBurned).toBe(200);
            expect(result.description).toBe('Original description');
        });
    });
});
//# sourceMappingURL=workout.integration.spec.js.map