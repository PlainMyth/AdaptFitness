import { Injectable, Logger, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WorkoutPlan } from './workout-plan.entity';
import { AiWorkoutPlanGeneratorService } from '../ai-workout-plan-generator/ai-workout-plan-generator.service';
import { GenerateWorkoutPlanDto } from '../ai-workout-plan-generator/dto/generate-workout-plan.dto';
import { WorkoutPlanResponseDto } from './dto/workout-plan-response.dto';

@Injectable()
export class WorkoutPlanService {
  private readonly logger = new Logger(WorkoutPlanService.name);

  constructor(
    @InjectRepository(WorkoutPlan)
    private readonly workoutPlanRepository: Repository<WorkoutPlan>,
    private readonly aiWorkoutPlanGeneratorService: AiWorkoutPlanGeneratorService,
  ) {}

  async generateAndSavePlan(userId: string, dto: GenerateWorkoutPlanDto): Promise<WorkoutPlanResponseDto> {
    this.logger.log(`Generating and saving workout plan for user ${userId}`);

    // Generate the workout plan using the AI service
    const aiResponse = await this.aiWorkoutPlanGeneratorService.generateWorkoutPlan(userId, dto);

    if (!aiResponse.success || !aiResponse.data) {
      throw new Error('Failed to generate workout plan');
    }

    // Deactivate any existing active plans for this user
    await this.workoutPlanRepository.update(
      { userId, isActive: true },
      { isActive: false },
    );

    // Create and save the new workout plan
    const workoutPlan = this.workoutPlanRepository.create({
      userId,
      name: aiResponse.data.plan_name || aiResponse.data.planName || 'Workout Plan',
      description: aiResponse.data.plan_description || aiResponse.data.planDescription || null,
      workoutPlanData: aiResponse.data,
      isActive: true,
      isCompleted: false,
    });

    const savedPlan = await this.workoutPlanRepository.save(workoutPlan);

    this.logger.log(`Workout plan saved successfully with ID: ${savedPlan.id}`);

    return this.mapToResponseDto(savedPlan);
  }

  async getActivePlan(userId: string): Promise<WorkoutPlanResponseDto | null> {
    this.logger.log(`Fetching active workout plan for user ${userId}`);

    const activePlan = await this.workoutPlanRepository.findOne({
      where: { userId, isActive: true },
    });

    if (!activePlan) {
      this.logger.log(`No active workout plan found for user ${userId}`);
      return null;
    }

    return this.mapToResponseDto(activePlan);
  }

  async retirePlan(userId: string, planId: string): Promise<WorkoutPlanResponseDto> {
    this.logger.log(`Retiring workout plan ${planId} for user ${userId}`);

    const plan = await this.workoutPlanRepository.findOne({
      where: { id: planId },
    });

    if (!plan) {
      throw new NotFoundException(`Workout plan with ID ${planId} not found`);
    }

    if (plan.userId !== userId) {
      throw new ForbiddenException('You do not have permission to retire this workout plan');
    }

    plan.isActive = false;
    plan.isCompleted = true;
    plan.completedAt = new Date();

    const updatedPlan = await this.workoutPlanRepository.save(plan);

    this.logger.log(`Workout plan ${planId} retired successfully`);

    return this.mapToResponseDto(updatedPlan);
  }

  async getPlanById(userId: string, planId: string): Promise<WorkoutPlanResponseDto> {
    this.logger.log(`Fetching workout plan ${planId} for user ${userId}`);

    const plan = await this.workoutPlanRepository.findOne({
      where: { id: planId },
    });

    if (!plan) {
      throw new NotFoundException(`Workout plan with ID ${planId} not found`);
    }

    if (plan.userId !== userId) {
      throw new ForbiddenException('You do not have permission to view this workout plan');
    }

    return this.mapToResponseDto(plan);
  }

  private mapToResponseDto(plan: WorkoutPlan): WorkoutPlanResponseDto {
    return {
      id: plan.id,
      userId: plan.userId,
      name: plan.name,
      description: plan.description,
      workoutPlanData: plan.workoutPlanData,
      isActive: plan.isActive,
      isCompleted: plan.isCompleted,
      completedAt: plan.completedAt,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    };
  }
}
