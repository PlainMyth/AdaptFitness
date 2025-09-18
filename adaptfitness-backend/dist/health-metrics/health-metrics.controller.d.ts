import { HealthMetricsService } from './health-metrics.service';
import { CreateHealthMetricsDto } from './dto/create-health-metrics.dto';
import { UpdateHealthMetricsDto } from './dto/update-health-metrics.dto';
export declare class HealthMetricsController {
    private readonly healthMetricsService;
    constructor(healthMetricsService: HealthMetricsService);
    create(createHealthMetricsDto: CreateHealthMetricsDto, req: any): Promise<import("./health-metrics.entity").HealthMetrics>;
    findAll(req: any): Promise<import("./health-metrics.entity").HealthMetrics[]>;
    findLatest(req: any): Promise<import("./health-metrics.entity").HealthMetrics>;
    getCalculatedMetrics(req: any): Promise<{
        bmi: number;
        tdee: number;
        rmr: number;
        bodyFatCategory: string;
        bmiCategory: string;
    }>;
    findOne(id: number, req: any): Promise<import("./health-metrics.entity").HealthMetrics>;
    update(id: number, updateHealthMetricsDto: UpdateHealthMetricsDto, req: any): Promise<import("./health-metrics.entity").HealthMetrics>;
    remove(id: number, req: any): Promise<void>;
}
