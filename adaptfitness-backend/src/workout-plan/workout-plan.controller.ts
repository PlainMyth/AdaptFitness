import { Controller, Post, Get, Put, Body, Request, Param, UseGuards, Logger } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { WorkoutPlanService } from './workout-plan.service';
import { GenerateWorkoutPlanDto } from '../ai-workout-plan-generator/dto/generate-workout-plan.dto';
import { WorkoutPlanResponseDto, ActivePlanResponseDto, GenerateAndSaveResponseDto } from './dto/workout-plan-response.dto';

@Controller('workout-plans')
@UseGuards(JwtAuthGuard)
export class WorkoutPlanController {
  private readonly logger = new Logger(WorkoutPlanController.name);

  constructor(private readonly workoutPlanService: WorkoutPlanService) {}

  @Post('generate-and-save')
  async generateAndSavePlan(
    @Request() req: any,
    @Body() dto: GenerateWorkoutPlanDto,
  ): Promise<GenerateAndSaveResponseDto> {
    const userId = req.user.id;
    this.logger.log(`POST /workout-plans/generate-and-save - User: ${userId}`);

    const plan = await this.workoutPlanService.generateAndSavePlan(userId, dto);

    return {
      success: true,
      data: plan,
      message: 'Workout plan generated and saved successfully',
    };
  }

  @Get('active')
  async getActivePlan(@Request() req: any): Promise<ActivePlanResponseDto> {
    const userId = req.user.id;
    this.logger.log(`GET /workout-plans/active - User: ${userId}`);

    const plan = await this.workoutPlanService.getActivePlan(userId);

    return {
      data: plan,
    };
  }

  @Put(':id/retire')
  async retirePlan(
    @Request() req: any,
    @Param('id') planId: string,
  ): Promise<WorkoutPlanResponseDto> {
    const userId = req.user.id;
    this.logger.log(`PUT /workout-plans/${planId}/retire - User: ${userId}`);

    return this.workoutPlanService.retirePlan(userId, planId);
  }

  @Get(':id')
  async getPlanById(
    @Request() req: any,
    @Param('id') planId: string,
  ): Promise<WorkoutPlanResponseDto> {
    const userId = req.user.id;
    this.logger.log(`GET /workout-plans/${planId} - User: ${userId}`);

    return this.workoutPlanService.getPlanById(userId, planId);
  }
}
