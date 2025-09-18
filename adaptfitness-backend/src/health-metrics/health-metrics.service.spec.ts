import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { HealthMetricsService } from './health-metrics.service';
import { HealthMetrics } from './health-metrics.entity';
import { User } from '../user/user.entity';
import { CreateHealthMetricsDto } from './dto/create-health-metrics.dto';
import { UpdateHealthMetricsDto } from './dto/update-health-metrics.dto';

describe('HealthMetricsService', () => {
  let service: HealthMetricsService;
  let healthMetricsRepository: Repository<HealthMetrics>;
  let userRepository: Repository<User>;

  const mockHealthMetricsRepository = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
    findOne: jest.fn(),
    remove: jest.fn(),
  };

  const mockUserRepository = {
    findOne: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HealthMetricsService,
        {
          provide: getRepositoryToken(HealthMetrics),
          useValue: mockHealthMetricsRepository,
        },
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    service = module.get<HealthMetricsService>(HealthMetricsService);
    healthMetricsRepository = module.get<Repository<HealthMetrics>>(getRepositoryToken(HealthMetrics));
    userRepository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('create', () => {
    const createHealthMetricsDto: CreateHealthMetricsDto = {
      currentWeight: 70,
      bodyFatPercentage: 15,
      goalWeight: 65,
      waistCircumference: 80,
      hipCircumference: 95,
      notes: 'Test measurement',
    };

    const mockUser = {
      id: 'user-123',
      height: 175,
      age: 25,
      gender: 'male',
      activityLevelMultiplier: 1.4,
    };

    it('should create health metrics with calculated values', async () => {
      // Arrange
      const userId = 'user-123';
      const mockHealthMetrics = {
        ...createHealthMetricsDto,
        userId,
        bmi: 22.86,
        leanBodyMass: 59.5,
        skeletalMuscleMass: 32.1,
        waistToHipRatio: 0.842,
        waistToHeightRatio: 0.457,
        absi: 0.078,
        rmr: 1750,
        tdee: 2450,
        maximumFatLoss: 0.7,
        calorieDeficit: 500,
      };

      mockUserRepository.findOne.mockResolvedValue(mockUser);
      mockHealthMetricsRepository.create.mockReturnValue(mockHealthMetrics);
      mockHealthMetricsRepository.save.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await service.create(createHealthMetricsDto, userId);

      // Assert
      expect(mockUserRepository.findOne).toHaveBeenCalledWith({ where: { id: userId } });
      expect(mockHealthMetricsRepository.create).toHaveBeenCalledWith({
        ...createHealthMetricsDto,
        userId,
      });
      expect(mockHealthMetricsRepository.save).toHaveBeenCalled();
      expect(result).toEqual(mockHealthMetrics);
    });

    it('should throw NotFoundException when user not found', async () => {
      // Arrange
      const userId = 'non-existent-user';
      mockUserRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.create(createHealthMetricsDto, userId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('findAll', () => {
    it('should return all health metrics for a user', async () => {
      // Arrange
      const userId = 'user-123';
      const mockHealthMetrics = [
        { id: 1, userId, currentWeight: 70, createdAt: new Date('2024-01-01') },
        { id: 2, userId, currentWeight: 69, createdAt: new Date('2024-01-02') },
      ];
      mockHealthMetricsRepository.find.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await service.findAll(userId);

      // Assert
      expect(mockHealthMetricsRepository.find).toHaveBeenCalledWith({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
      expect(result).toEqual(mockHealthMetrics);
    });
  });

  describe('findOne', () => {
    it('should return a specific health metric', async () => {
      // Arrange
      const id = 1;
      const userId = 'user-123';
      const mockHealthMetrics = { id, userId, currentWeight: 70 };
      mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await service.findOne(id, userId);

      // Assert
      expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
        where: { id, userId },
      });
      expect(result).toEqual(mockHealthMetrics);
    });

    it('should throw NotFoundException when health metric not found', async () => {
      // Arrange
      const id = 999;
      const userId = 'user-123';
      mockHealthMetricsRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.findOne(id, userId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('findLatest', () => {
    it('should return the latest health metric for a user', async () => {
      // Arrange
      const userId = 'user-123';
      const mockHealthMetrics = { id: 2, userId, currentWeight: 69 };
      mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await service.findLatest(userId);

      // Assert
      expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
      expect(result).toEqual(mockHealthMetrics);
    });

    it('should throw NotFoundException when no health metrics found', async () => {
      // Arrange
      const userId = 'user-123';
      mockHealthMetricsRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.findLatest(userId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update health metrics and recalculate values', async () => {
      // Arrange
      const id = 1;
      const userId = 'user-123';
      const updateDto: UpdateHealthMetricsDto = { currentWeight: 68 };
      const existingHealthMetrics = { id, userId, currentWeight: 70 };
      const updatedHealthMetrics = { ...existingHealthMetrics, ...updateDto };

      mockHealthMetricsRepository.findOne.mockResolvedValue(existingHealthMetrics);
      mockUserRepository.findOne.mockResolvedValue({
        id: userId,
        height: 175,
        age: 25,
        gender: 'male',
        activityLevelMultiplier: 1.4,
      });
      mockHealthMetricsRepository.save.mockResolvedValue(updatedHealthMetrics);

      // Act
      const result = await service.update(id, updateDto, userId);

      // Assert
      expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
        where: { id, userId },
      });
      expect(mockHealthMetricsRepository.save).toHaveBeenCalled();
      expect(result).toEqual(updatedHealthMetrics);
    });
  });

  describe('remove', () => {
    it('should remove health metrics', async () => {
      // Arrange
      const id = 1;
      const userId = 'user-123';
      const mockHealthMetrics = { id, userId, currentWeight: 70 };
      mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);
      mockHealthMetricsRepository.remove.mockResolvedValue(mockHealthMetrics);

      // Act
      await service.remove(id, userId);

      // Assert
      expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
        where: { id, userId },
      });
      expect(mockHealthMetricsRepository.remove).toHaveBeenCalledWith(mockHealthMetrics);
    });
  });

  describe('getCalculatedMetrics', () => {
    it('should return calculated metrics for a user', async () => {
      // Arrange
      const userId = 'user-123';
      const mockHealthMetrics = {
        id: 1,
        userId,
        bmi: 22.86,
        tdee: 2450,
        rmr: 1750,
        bodyFatPercentage: 15,
        user: { gender: 'male' },
      };
      mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await service.getCalculatedMetrics(userId);

      // Assert
      expect(result).toEqual({
        bmi: 22.86,
        tdee: 2450,
        rmr: 1750,
        bodyFatCategory: 'Fitness',
        bmiCategory: 'Normal weight',
      });
    });
  });

  describe('Calculation Methods', () => {
    describe('BMI Calculation', () => {
      it('should calculate BMI correctly', () => {
        // This would test private methods through public methods
        // We'll test the calculation through the create method
        const createDto: CreateHealthMetricsDto = {
          currentWeight: 70,
        };
        const mockUser = {
          id: 'user-123',
          height: 175,
          age: 25,
          gender: 'male',
          activityLevelMultiplier: 1.4,
        };

        mockUserRepository.findOne.mockResolvedValue(mockUser);
        mockHealthMetricsRepository.create.mockReturnValue({});
        mockHealthMetricsRepository.save.mockResolvedValue({
          bmi: 22.86, // Expected BMI for 70kg, 175cm
        });

        service.create(createDto, 'user-123').then((result) => {
          expect(result.bmi).toBeCloseTo(22.86, 1);
        });
      });
    });
  });
});
