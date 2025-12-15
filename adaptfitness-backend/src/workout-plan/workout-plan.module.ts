import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WorkoutPlan } from './workout-plan.entity';
import { WorkoutPlanController } from './workout-plan.controller';
import { WorkoutPlanService } from './workout-plan.service';
import { AiWorkoutPlanGeneratorModule } from '../ai-workout-plan-generator/ai-workout-plan-generator.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([WorkoutPlan]),
    AiWorkoutPlanGeneratorModule,
  ],
  controllers: [WorkoutPlanController],
  providers: [WorkoutPlanService],
  exports: [WorkoutPlanService],
})
export class WorkoutPlanModule {}
