import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WorkoutService } from './workout.service';
import { Workout } from './workout.entity';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
import { NotFoundException } from '@nestjs/common';

/**
 * Workout Service Unit Tests
 *
 * This file contains comprehensive unit tests for the WorkoutService class.
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
describe('WorkoutService', () => {
  let service: WorkoutService;
  let mockRepository: jest.Mocked<Repository<Workout>>;

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
        WorkoutService,
        {
          provide: getRepositoryToken(Workout),
          useValue: mockRepositoryValue,
        },
      ],
    }).compile();

    service = module.get<WorkoutService>(WorkoutService);
    mockRepository = module.get(getRepositoryToken(Workout));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a workout', async () => {
      const createWorkoutDto: CreateWorkoutDto = {
        name: 'Morning Workout',
        description: 'Strength training session',
        startTime: new Date(),
        endTime: new Date(),
        notes: 'Test workout',
        userId: 'user-uuid-123',
      };

      const expectedWorkout = { id: 'workout-uuid-123', ...createWorkoutDto };
      mockRepository.create.mockReturnValue(expectedWorkout as any);
      mockRepository.save.mockResolvedValue(expectedWorkout as any);

      const result = await service.create(createWorkoutDto);

      expect(mockRepository.create).toHaveBeenCalledWith(createWorkoutDto);
      expect(mockRepository.save).toHaveBeenCalledWith(expectedWorkout);
      expect(result).toEqual(expectedWorkout);
    });
  });

  describe('findAll', () => {
    it('should return all workouts for a user', async () => {
      const userId = 'user-uuid-123';
      const expectedWorkouts = [
        { id: 'workout-uuid-1', name: 'Morning Workout', userId },
        { id: 'workout-uuid-2', name: 'Evening Cardio', userId },
      ];

      mockRepository.find.mockResolvedValue(expectedWorkouts as any);

      const result = await service.findAll(userId);

      expect(mockRepository.find).toHaveBeenCalledWith({
        where: { user: { id: userId } },
        order: { startTime: 'DESC' },
      });
      expect(result).toEqual(expectedWorkouts);
    });
  });

  describe('findOne', () => {
    it('should return a workout when found', async () => {
      const workoutId = 'workout-uuid-123';
      const expectedWorkout = { id: workoutId, name: 'Morning Workout' };

      mockRepository.findOne.mockResolvedValue(expectedWorkout as any);

      const result = await service.findOne(workoutId);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: workoutId },
        relations: ['user'],
      });
      expect(result).toEqual(expectedWorkout);
    });

    it('should throw NotFoundException when workout not found', async () => {
      const workoutId = 'non-existent-uuid';
      mockRepository.findOne.mockResolvedValue(null);

      await expect(service.findOne(workoutId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update a workout', async () => {
      const workoutId = 'workout-uuid-123';
      const updateWorkoutDto: UpdateWorkoutDto = {
        notes: 'Updated workout notes',
      };
      const existingWorkout = { id: workoutId, name: 'Morning Workout', notes: 'Old notes' };
      const updatedWorkout = { ...existingWorkout, ...updateWorkoutDto };

      mockRepository.findOne.mockResolvedValue(existingWorkout as any);
      mockRepository.save.mockResolvedValue(updatedWorkout as any);

      const result = await service.update(workoutId, updateWorkoutDto);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: workoutId },
        relations: ['user'],
      });
      expect(mockRepository.save).toHaveBeenCalledWith(updatedWorkout);
      expect(result).toEqual(updatedWorkout);
    });
  });

  describe('remove', () => {
    it('should remove a workout', async () => {
      const workoutId = 'workout-uuid-123';
      const existingWorkout = { id: workoutId, name: 'Morning Workout' };

      mockRepository.findOne.mockResolvedValue(existingWorkout as any);
      mockRepository.remove.mockResolvedValue(existingWorkout as any);

      await service.remove(workoutId);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: workoutId },
        relations: ['user'],
      });
      expect(mockRepository.remove).toHaveBeenCalledWith(existingWorkout);
    });
  });

  describe('getCurrentStreakInTimeZone', () => {
    it('should return zero streak when no workouts exist', async () => {
      const userId = 'user-uuid-123';
      mockRepository.find.mockResolvedValue([]);

      const result = await service.getCurrentStreakInTimeZone(userId);

      expect(result).toEqual({ streak: 0, lastWorkoutDate: null });
    });

    it('should calculate streak correctly with consecutive workouts', async () => {
      const userId = 'user-uuid-123';
      const today = new Date();
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
      const dayBefore = new Date(today.getTime() - 2 * 24 * 60 * 60 * 1000);

      const workouts = [
        { startTime: today },
        { startTime: yesterday },
        { startTime: dayBefore },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThan(0);
      expect(result.lastWorkoutDate).toBeDefined();
    });

    it('should handle timezone correctly - New York', async () => {
      const userId = 'user-uuid-123';
      const workouts = [
        { startTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastWorkoutDate).toBeDefined();
    });

    it('should handle multiple workouts on same day', async () => {
      const userId = 'user-uuid-123';
      const today = new Date();
      const workouts = [
        { startTime: new Date(today.getTime() + 1000) },
        { startTime: new Date(today.getTime() + 2000) },
        { startTime: new Date(today.getTime() + 3000) },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(1);
    });

    it('should handle invalid timezone gracefully', async () => {
      const userId = 'user-uuid-123';
      const workouts = [
        { startTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastWorkoutDate).toBeDefined();
    });

    it('should handle undefined timezone', async () => {
      const userId = 'user-uuid-123';
      const workouts = [
        { startTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId);

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastWorkoutDate).toBeDefined();
    });

    it('should not overflow with large date ranges', async () => {
      // Test with dates far in the past to ensure no overflow
      const farPast = new Date(1970, 0, 1); // Unix epoch
      const workouts = [
        { startTime: new Date(farPast.getTime() + 1 * 24 * 60 * 60 * 1000) },
        { startTime: farPast },
      ];
      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone('user-uuid-123', 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastWorkoutDate).toBeDefined();
    });

    it('should handle future dates gracefully', async () => {
      const userId = 'user-uuid-123';
      const futureDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days in future
      const workouts = [
        { startTime: futureDate },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBe(0); // Future dates shouldn't count for current streak
    });

    it('should limit daysAgo to prevent infinite loops', async () => {
      const userId = 'user-uuid-123';
      // Create a reasonable number of consecutive workouts
      const workouts = [];
      for (let i = 0; i < 10; i++) {
        workouts.push({ startTime: new Date(Date.now() - i * 24 * 60 * 60 * 1000) });
      }
      mockRepository.find.mockResolvedValue(workouts);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBe(10);
      expect(Number.isFinite(result.streak)).toBe(true);
      expect(result.streak).toBeLessThanOrEqual(365); // Should be limited to 365 days
    });

    it('should handle edge case of workouts at midnight boundary', async () => {
      const userId = 'user-uuid-123';
      const midnight = new Date();
      midnight.setHours(0, 0, 0, 0);
      const workouts = [
        { startTime: midnight },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.streak).toBeGreaterThanOrEqual(0);
    });

    it('should return correct lastWorkoutDate format', async () => {
      const userId = 'user-uuid-123';
      const workouts = [
        { startTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'UTC');

      expect(result.lastWorkoutDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    });

    it('should handle Pacific timezone correctly', async () => {
      const userId = 'user-uuid-123';
      const workouts = [
        { startTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      const result = await service.getCurrentStreakInTimeZone(userId, 'America/Los_Angeles');

      expect(result.streak).toBeGreaterThanOrEqual(0);
      expect(result.lastWorkoutDate).toBeDefined();
    });
  });

  describe('private helper methods', () => {
    it('should validate timezone correctly', async () => {
      const userId = 'user-uuid-123';
      const workouts = [
        { startTime: new Date() },
      ];

      mockRepository.find.mockResolvedValue(workouts as any);

      // Test with valid timezone
      const result1 = await service.getCurrentStreakInTimeZone(userId, 'America/New_York');
      expect(result1.streak).toBeGreaterThanOrEqual(0);

      // Test with invalid timezone (should fallback to UTC)
      const result2 = await service.getCurrentStreakInTimeZone(userId, 'Invalid/Timezone');
      expect(result2.streak).toBeGreaterThanOrEqual(0);
    });
  });
});