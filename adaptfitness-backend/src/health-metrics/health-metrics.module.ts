import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HealthMetricsService } from './health-metrics.service';
import { HealthMetricsController } from './health-metrics.controller';
import { HealthMetrics } from './health-metrics.entity';
import { User } from '../user/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([HealthMetrics, User])],
  controllers: [HealthMetricsController],
  providers: [HealthMetricsService],
  exports: [HealthMetricsService],
})
export class HealthMetricsModule {}
