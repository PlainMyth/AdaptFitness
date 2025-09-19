import { Test, TestingModule } from '@nestjs/testing';
import { HealthMetricsController } from './health-metrics.controller';
import { HealthMetricsService } from './health-metrics.service';
import { CreateHealthMetricsDto } from './dto/create-health-metrics.dto';
import { UpdateHealthMetricsDto } from './dto/update-health-metrics.dto';
import { NotFoundException } from '@nestjs/common';

describe('HealthMetricsController', () => {
  let controller: HealthMetricsController;
  let service: HealthMetricsService;

  const mockHealthMetricsService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    findLatest: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
    getCalculatedMetrics: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthMetricsController],
      providers: [
        {
          provide: HealthMetricsService,
          useValue: mockHealthMetricsService,
        },
      ],
    }).compile();

    controller = module.get<HealthMetricsController>(HealthMetricsController);
    service = module.get<HealthMetricsService>(HealthMetricsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create health metrics', async () => {
      // Arrange
      const createDto: CreateHealthMetricsDto = {
        currentWeight: 70,
        bodyFatPercentage: 15,
        goalWeight: 65,
        waistCircumference: 80,
        hipCircumference: 95,
        notes: 'Test measurement',
      };
      const mockRequest = { user: { id: 'user-123' } };
      const mockHealthMetrics = {
        id: 1,
        userId: 'user-123',
        ...createDto,
        bmi: 22.86,
        leanBodyMass: 59.5,
        tdee: 2450,
        rmr: 1750,
      };

      mockHealthMetricsService.create.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await controller.create(createDto, mockRequest);

      // Assert
      expect(service.create).toHaveBeenCalledWith(createDto, 'user-123');
      expect(result).toEqual(mockHealthMetrics);
    });
  });

  describe('findAll', () => {
    it('should return all health metrics for a user', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      const mockHealthMetrics = [
        { id: 1, userId: 'user-123', currentWeight: 70, createdAt: new Date('2024-01-01') },
        { id: 2, userId: 'user-123', currentWeight: 69, createdAt: new Date('2024-01-02') },
      ];

      mockHealthMetricsService.findAll.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await controller.findAll(mockRequest);

      // Assert
      expect(service.findAll).toHaveBeenCalledWith('user-123');
      expect(result).toEqual(mockHealthMetrics);
    });
  });

  describe('findLatest', () => {
    it('should return the latest health metrics for a user', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      const mockHealthMetrics = {
        id: 2,
        userId: 'user-123',
        currentWeight: 69,
        bmi: 22.45,
        tdee: 2400,
        rmr: 1700,
      };

      mockHealthMetricsService.findLatest.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await controller.findLatest(mockRequest);

      // Assert
      expect(service.findLatest).toHaveBeenCalledWith('user-123');
      expect(result).toEqual(mockHealthMetrics);
    });
  });

  describe('getCalculatedMetrics', () => {
    it('should return calculated metrics for a user', async () => {
      // Arrange
      const mockRequest = { user: { id: 'user-123' } };
      const mockCalculatedMetrics = {
        bmi: 22.86,
        tdee: 2450,
        rmr: 1750,
        bodyFatCategory: 'Fitness',
        bmiCategory: 'Normal weight',
      };

      mockHealthMetricsService.getCalculatedMetrics.mockResolvedValue(mockCalculatedMetrics);

      // Act
      const result = await controller.getCalculatedMetrics(mockRequest);

      // Assert
      expect(service.getCalculatedMetrics).toHaveBeenCalledWith('user-123');
      expect(result).toEqual(mockCalculatedMetrics);
    });
  });

  describe('findOne', () => {
    it('should return a specific health metric', async () => {
      // Arrange
      const id = 1;
      const mockRequest = { user: { id: 'user-123' } };
      const mockHealthMetrics = {
        id,
        userId: 'user-123',
        currentWeight: 70,
        bmi: 22.86,
        tdee: 2450,
        rmr: 1750,
      };

      mockHealthMetricsService.findOne.mockResolvedValue(mockHealthMetrics);

      // Act
      const result = await controller.findOne(id, mockRequest);

      // Assert
      expect(service.findOne).toHaveBeenCalledWith(id, 'user-123');
      expect(result).toEqual(mockHealthMetrics);
    });

    it('should throw NotFoundException when health metric not found', async () => {
      // Arrange
      const id = 999;
      const mockRequest = { user: { id: 'user-123' } };

      mockHealthMetricsService.findOne.mockRejectedValue(new NotFoundException('Health metrics not found'));

      // Act & Assert
      await expect(controller.findOne(id, mockRequest)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update health metrics', async () => {
      // Arrange
      const id = 1;
      const updateDto: UpdateHealthMetricsDto = { currentWeight: 68 };
      const mockRequest = { user: { id: 'user-123' } };
      const mockUpdatedHealthMetrics = {
        id,
        userId: 'user-123',
        currentWeight: 68,
        bmi: 22.2,
        tdee: 2400,
        rmr: 1700,
      };

      mockHealthMetricsService.update.mockResolvedValue(mockUpdatedHealthMetrics);

      // Act
      const result = await controller.update(id, updateDto, mockRequest);

      // Assert
      expect(service.update).toHaveBeenCalledWith(id, updateDto, 'user-123');
      expect(result).toEqual(mockUpdatedHealthMetrics);
    });
  });

  describe('remove', () => {
    it('should remove health metrics', async () => {
      // Arrange
      const id = 1;
      const mockRequest = { user: { id: 'user-123' } };

      mockHealthMetricsService.remove.mockResolvedValue(undefined);

      // Act
      await controller.remove(id, mockRequest);

      // Assert
      expect(service.remove).toHaveBeenCalledWith(id, 'user-123');
    });
  });
});
