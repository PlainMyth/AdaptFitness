import { Repository } from 'typeorm';
import { HealthMetrics } from './health-metrics.entity';
import { User } from '../user/user.entity';
import { CreateHealthMetricsDto } from './dto/create-health-metrics.dto';
import { UpdateHealthMetricsDto } from './dto/update-health-metrics.dto';
export declare class HealthMetricsService {
    private healthMetricsRepository;
    private userRepository;
    constructor(healthMetricsRepository: Repository<HealthMetrics>, userRepository: Repository<User>);
    create(createHealthMetricsDto: CreateHealthMetricsDto, userId: string): Promise<HealthMetrics>;
    findAll(userId: string): Promise<HealthMetrics[]>;
    findOne(id: number, userId: string): Promise<HealthMetrics>;
    findLatest(userId: string): Promise<HealthMetrics>;
    update(id: number, updateHealthMetricsDto: UpdateHealthMetricsDto, userId: string): Promise<HealthMetrics>;
    remove(id: number, userId: string): Promise<void>;
    private calculateAllMetrics;
    private calculateBMI;
    private calculateLeanBodyMass;
    private calculateSkeletalMuscleMass;
    private calculateWaistToHipRatio;
    private calculateWaistToHeightRatio;
    private calculateABSI;
    private calculateRMR;
    private calculateTDEE;
    private calculateMaximumFatLoss;
    private calculateCalorieDeficit;
    private getUserData;
    getCalculatedMetrics(userId: string): Promise<{
        bmi: number;
        tdee: number;
        rmr: number;
        bodyFatCategory: string;
        bmiCategory: string;
    }>;
    private getBodyFatCategory;
    private getBMICategory;
}
