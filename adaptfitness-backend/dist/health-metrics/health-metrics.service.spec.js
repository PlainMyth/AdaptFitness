"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const typeorm_1 = require("@nestjs/typeorm");
const common_1 = require("@nestjs/common");
const health_metrics_service_1 = require("./health-metrics.service");
const health_metrics_entity_1 = require("./health-metrics.entity");
const user_entity_1 = require("../user/user.entity");
describe('HealthMetricsService', () => {
    let service;
    let healthMetricsRepository;
    let userRepository;
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
        const module = await testing_1.Test.createTestingModule({
            providers: [
                health_metrics_service_1.HealthMetricsService,
                {
                    provide: (0, typeorm_1.getRepositoryToken)(health_metrics_entity_1.HealthMetrics),
                    useValue: mockHealthMetricsRepository,
                },
                {
                    provide: (0, typeorm_1.getRepositoryToken)(user_entity_1.User),
                    useValue: mockUserRepository,
                },
            ],
        }).compile();
        service = module.get(health_metrics_service_1.HealthMetricsService);
        healthMetricsRepository = module.get((0, typeorm_1.getRepositoryToken)(health_metrics_entity_1.HealthMetrics));
        userRepository = module.get((0, typeorm_1.getRepositoryToken)(user_entity_1.User));
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    describe('create', () => {
        const createHealthMetricsDto = {
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
            const result = await service.create(createHealthMetricsDto, userId);
            expect(mockUserRepository.findOne).toHaveBeenCalledWith({ where: { id: userId } });
            expect(mockHealthMetricsRepository.create).toHaveBeenCalledWith({
                ...createHealthMetricsDto,
                userId,
            });
            expect(mockHealthMetricsRepository.save).toHaveBeenCalled();
            expect(result).toEqual(mockHealthMetrics);
        });
        it('should throw NotFoundException when user not found', async () => {
            const userId = 'non-existent-user';
            mockUserRepository.findOne.mockResolvedValue(null);
            await expect(service.create(createHealthMetricsDto, userId)).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('findAll', () => {
        it('should return all health metrics for a user', async () => {
            const userId = 'user-123';
            const mockHealthMetrics = [
                { id: 1, userId, currentWeight: 70, createdAt: new Date('2024-01-01') },
                { id: 2, userId, currentWeight: 69, createdAt: new Date('2024-01-02') },
            ];
            mockHealthMetricsRepository.find.mockResolvedValue(mockHealthMetrics);
            const result = await service.findAll(userId);
            expect(mockHealthMetricsRepository.find).toHaveBeenCalledWith({
                where: { userId },
                order: { createdAt: 'DESC' },
            });
            expect(result).toEqual(mockHealthMetrics);
        });
    });
    describe('findOne', () => {
        it('should return a specific health metric', async () => {
            const id = 1;
            const userId = 'user-123';
            const mockHealthMetrics = { id, userId, currentWeight: 70 };
            mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);
            const result = await service.findOne(id, userId);
            expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
                where: { id, userId },
            });
            expect(result).toEqual(mockHealthMetrics);
        });
        it('should throw NotFoundException when health metric not found', async () => {
            const id = 999;
            const userId = 'user-123';
            mockHealthMetricsRepository.findOne.mockResolvedValue(null);
            await expect(service.findOne(id, userId)).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('findLatest', () => {
        it('should return the latest health metric for a user', async () => {
            const userId = 'user-123';
            const mockHealthMetrics = { id: 2, userId, currentWeight: 69 };
            mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);
            const result = await service.findLatest(userId);
            expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
                where: { userId },
                order: { createdAt: 'DESC' },
            });
            expect(result).toEqual(mockHealthMetrics);
        });
        it('should throw NotFoundException when no health metrics found', async () => {
            const userId = 'user-123';
            mockHealthMetricsRepository.findOne.mockResolvedValue(null);
            await expect(service.findLatest(userId)).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('update', () => {
        it('should update health metrics and recalculate values', async () => {
            const id = 1;
            const userId = 'user-123';
            const updateDto = { currentWeight: 68 };
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
            const result = await service.update(id, updateDto, userId);
            expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
                where: { id, userId },
            });
            expect(mockHealthMetricsRepository.save).toHaveBeenCalled();
            expect(result).toEqual(updatedHealthMetrics);
        });
    });
    describe('remove', () => {
        it('should remove health metrics', async () => {
            const id = 1;
            const userId = 'user-123';
            const mockHealthMetrics = { id, userId, currentWeight: 70 };
            mockHealthMetricsRepository.findOne.mockResolvedValue(mockHealthMetrics);
            mockHealthMetricsRepository.remove.mockResolvedValue(mockHealthMetrics);
            await service.remove(id, userId);
            expect(mockHealthMetricsRepository.findOne).toHaveBeenCalledWith({
                where: { id, userId },
            });
            expect(mockHealthMetricsRepository.remove).toHaveBeenCalledWith(mockHealthMetrics);
        });
    });
    describe('getCalculatedMetrics', () => {
        it('should return calculated metrics for a user', async () => {
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
            const result = await service.getCalculatedMetrics(userId);
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
                const createDto = {
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
                    bmi: 22.86,
                });
                service.create(createDto, 'user-123').then((result) => {
                    expect(result.bmi).toBeCloseTo(22.86, 1);
                });
            });
        });
    });
});
//# sourceMappingURL=health-metrics.service.spec.js.map