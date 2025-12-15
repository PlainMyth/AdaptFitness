import { Controller, Post, Get, Body, Request, Query, Param, UseGuards, Logger } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AiWorkoutPlanGeneratorService } from './ai-workout-plan-generator.service';
import { ExerciseDbService } from './exercise-db.service';
import { GenerateWorkoutPlanDto } from './dto/generate-workout-plan.dto';
import { WorkoutPlanResponseDto } from './dto/workout-plan-response.dto';

@Controller('ai-workout-plans')
@UseGuards(JwtAuthGuard)
export class AiWorkoutPlanGeneratorController {
  private readonly logger = new Logger(AiWorkoutPlanGeneratorController.name);

  constructor(
    private readonly aiWorkoutPlanGeneratorService: AiWorkoutPlanGeneratorService,
    private readonly exerciseDbService: ExerciseDbService,
  ) {}

  @Post('generate')
  async generateWorkoutPlan(
    @Request() req: any,
    @Body() dto: GenerateWorkoutPlanDto,
  ): Promise<WorkoutPlanResponseDto> {
    const userId = req.user.id;
    this.logger.log(`POST /ai-workout-plans/generate - User: ${userId}`);
    return this.aiWorkoutPlanGeneratorService.generateWorkoutPlan(userId, dto);
  }

  @Get('test-connection')
  async testConnection(): Promise<{
    gemini: { success: boolean; message: string };
    exerciseDb: { success: boolean; message: string };
  }> {
    this.logger.log('GET /ai-workout-plans/test-connection');
    return this.aiWorkoutPlanGeneratorService.testConnections();
  }

  @Get('exercises/search')
  async searchExercises(@Query('query') query: string): Promise<any> {
    this.logger.log(`GET /ai-workout-plans/exercises/search?query=${query}`);

    if (!query) {
      return {
        success: false,
        message: 'Query parameter is required',
        data: { data: [] },
      };
    }

    const result = await this.exerciseDbService.searchExercises(query);
    return {
      success: result.success,
      data: result.data?.data || [],
      message: result.success ? 'Search completed successfully' : 'Search failed',
    };
  }

  @Get('exercises/:id')
  async getExerciseById(@Param('id') id: string): Promise<any> {
    this.logger.log(`GET /ai-workout-plans/exercises/${id}`);

    if (!id) {
      return {
        success: false,
        message: 'Exercise ID is required',
        data: null,
      };
    }

    const result = await this.exerciseDbService.getExerciseById(id);
    return {
      success: result.success,
      data: result.data,
      message: result.success ? 'Exercise details retrieved successfully' : 'Exercise not found',
    };
  }
}
