"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const health_metrics_controller_1 = require("./health-metrics.controller");
const health_metrics_service_1 = require("./health-metrics.service");
const common_1 = require("@nestjs/common");
describe('HealthMetricsController', () => {
    let controller;
    let service;
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
        const module = await testing_1.Test.createTestingModule({
            controllers: [health_metrics_controller_1.HealthMetricsController],
            providers: [
                {
                    provide: health_metrics_service_1.HealthMetricsService,
                    useValue: mockHealthMetricsService,
                },
            ],
        }).compile();
        controller = module.get(health_metrics_controller_1.HealthMetricsController);
        service = module.get(health_metrics_service_1.HealthMetricsService);
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    describe('create', () => {
        it('should create health metrics', async () => {
            const createDto = {
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
            const result = await controller.create(createDto, mockRequest);
            expect(service.create).toHaveBeenCalledWith(createDto, 'user-123');
            expect(result).toEqual(mockHealthMetrics);
        });
    });
    describe('findAll', () => {
        it('should return all health metrics for a user', async () => {
            const mockRequest = { user: { id: 'user-123' } };
            const mockHealthMetrics = [
                { id: 1, userId: 'user-123', currentWeight: 70, createdAt: new Date('2024-01-01') },
                { id: 2, userId: 'user-123', currentWeight: 69, createdAt: new Date('2024-01-02') },
            ];
            mockHealthMetricsService.findAll.mockResolvedValue(mockHealthMetrics);
            const result = await controller.findAll(mockRequest);
            expect(service.findAll).toHaveBeenCalledWith('user-123');
            expect(result).toEqual(mockHealthMetrics);
        });
    });
    describe('findLatest', () => {
        it('should return the latest health metrics for a user', async () => {
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
            const result = await controller.findLatest(mockRequest);
            expect(service.findLatest).toHaveBeenCalledWith('user-123');
            expect(result).toEqual(mockHealthMetrics);
        });
    });
    describe('getCalculatedMetrics', () => {
        it('should return calculated metrics for a user', async () => {
            const mockRequest = { user: { id: 'user-123' } };
            const mockCalculatedMetrics = {
                bmi: 22.86,
                tdee: 2450,
                rmr: 1750,
                bodyFatCategory: 'Fitness',
                bmiCategory: 'Normal weight',
            };
            mockHealthMetricsService.getCalculatedMetrics.mockResolvedValue(mockCalculatedMetrics);
            const result = await controller.getCalculatedMetrics(mockRequest);
            expect(service.getCalculatedMetrics).toHaveBeenCalledWith('user-123');
            expect(result).toEqual(mockCalculatedMetrics);
        });
    });
    describe('findOne', () => {
        it('should return a specific health metric', async () => {
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
            const result = await controller.findOne(id, mockRequest);
            expect(service.findOne).toHaveBeenCalledWith(id, 'user-123');
            expect(result).toEqual(mockHealthMetrics);
        });
        it('should throw NotFoundException when health metric not found', async () => {
            const id = 999;
            const mockRequest = { user: { id: 'user-123' } };
            mockHealthMetricsService.findOne.mockRejectedValue(new common_1.NotFoundException('Health metrics not found'));
            await expect(controller.findOne(id, mockRequest)).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('update', () => {
        it('should update health metrics', async () => {
            const id = 1;
            const updateDto = { currentWeight: 68 };
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
            const result = await controller.update(id, updateDto, mockRequest);
            expect(service.update).toHaveBeenCalledWith(id, updateDto, 'user-123');
            expect(result).toEqual(mockUpdatedHealthMetrics);
        });
    });
    describe('remove', () => {
        it('should remove health metrics', async () => {
            const id = 1;
            const mockRequest = { user: { id: 'user-123' } };
            mockHealthMetricsService.remove.mockResolvedValue(undefined);
            await controller.remove(id, mockRequest);
            expect(service.remove).toHaveBeenCalledWith(id, 'user-123');
        });
    });
});
//# sourceMappingURL=health-metrics.controller.spec.js.map