import { Injectable, Logger, NotFoundException, BadRequestException, HttpException, HttpStatus } from '@nestjs/common';
import { GeminiAiService } from './gemini-ai.service';
import { ExerciseDbService } from './exercise-db.service';
import { UserService } from '../user/user.service';
import { GenerateWorkoutPlanDto } from './dto/generate-workout-plan.dto';
import { WorkoutPlanResponseDto } from './dto/workout-plan-response.dto';
import { UserProfileDto } from './dto/user-profile.dto';

@Injectable()
export class AiWorkoutPlanGeneratorService {
  private readonly logger = new Logger(AiWorkoutPlanGeneratorService.name);

  constructor(
    private readonly geminiAiService: GeminiAiService,
    private readonly exerciseDbService: ExerciseDbService,
    private readonly userService: UserService,
  ) {}

  async generateWorkoutPlan(userId: string, dto: GenerateWorkoutPlanDto): Promise<WorkoutPlanResponseDto> {
    try {
      this.logger.log(`Generating workout plan for user ${userId}`);
      this.logger.debug(`Request params: ${JSON.stringify(dto)}`);

      // Validate request
      this.validateWorkoutPlanRequest(dto);

      // Fetch user from database
      const user = await this.userService.findById(userId);
      if (!user) {
        throw new NotFoundException(`User with ID ${userId} not found`);
      }

      // Build user profile
      const userProfile = this.buildUserProfile(user);
      this.logger.debug(`User profile: ${JSON.stringify(userProfile)}`);

      // Generate workout plan using Gemini AI
      this.logger.log('Calling Gemini AI to generate workout plan...');
      let geminiResponse;
      try {
        geminiResponse = await this.geminiAiService.generateExercisePlan(
          dto.userGoal,
          dto.experienceLevel,
          dto.daysPerWeek,
          userProfile,
        );
      } catch (error) {
        this.logger.error(`Gemini API error: ${error.message}`, error.stack);
        throw new HttpException(
          'AI service temporarily unavailable. Please try again later.',
          HttpStatus.SERVICE_UNAVAILABLE,
        );
      }

      if (!geminiResponse.success) {
        throw new HttpException(
          geminiResponse.error || 'Failed to generate workout plan',
          HttpStatus.INTERNAL_SERVER_ERROR,
        );
      }

      this.logger.log('Workout plan generated successfully');

      // Enrich workout plan with ExerciseDB data
      this.logger.log('Enriching workout plan with ExerciseDB data...');
      let enrichedPlan;
      try {
        enrichedPlan = await this.exerciseDbService.enrichWorkoutPlan(geminiResponse);
      } catch (error) {
        this.logger.warn(`Exercise enrichment failed: ${error.message}`);
        // Return plan without enrichment if enrichment fails (non-blocking error)
        return {
          success: true,
          data: geminiResponse.data,
          message: 'Workout plan generated successfully (enrichment unavailable)',
        };
      }

      if (enrichedPlan.success) {
        this.logger.log(`Enrichment successful. Stats: ${JSON.stringify(enrichedPlan.enrichmentStats)}`);
        return {
          success: true,
          data: enrichedPlan.data,
          enrichmentStats: enrichedPlan.enrichmentStats,
          message: 'Workout plan generated and enriched successfully',
        };
      } else {
        // Enrichment failed, but return the plan anyway
        this.logger.warn('Enrichment failed, returning plan without enrichment');
        return {
          success: true,
          data: geminiResponse.data,
          message: 'Workout plan generated successfully (enrichment failed)',
        };
      }
    } catch (error) {
      if (error instanceof NotFoundException || error instanceof BadRequestException || error instanceof HttpException) {
        throw error;
      }

      this.logger.error(`Error generating workout plan: ${error.message}`, error.stack);
      throw new HttpException(
        'An error occurred while generating the workout plan',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  async testConnections(): Promise<{ gemini: { success: boolean; message: string }; exerciseDb: { success: boolean; message: string } }> {
    this.logger.log('Testing API connections...');

    const geminiTest = await this.geminiAiService.testConnection();
    const exerciseDbTest = await this.exerciseDbService.testConnection();

    return {
      gemini: geminiTest,
      exerciseDb: exerciseDbTest,
    };
  }

  private validateWorkoutPlanRequest(dto: GenerateWorkoutPlanDto): void {
    if (!dto.userGoal || !dto.experienceLevel || !dto.daysPerWeek) {
      throw new BadRequestException('Missing required fields: userGoal, experienceLevel, or daysPerWeek');
    }

    // userGoal is now free-form text - users can describe their goals in their own words

    const validLevels = ['beginner', 'intermediate', 'advanced'];
    if (!validLevels.includes(dto.experienceLevel)) {
      throw new BadRequestException(`Invalid experienceLevel. Must be one of: ${validLevels.join(', ')}`);
    }

    if (dto.daysPerWeek < 3 || dto.daysPerWeek > 7) {
      throw new BadRequestException('daysPerWeek must be between 3 and 7');
    }
  }

  private buildUserProfile(user: any): UserProfileDto {
    return {
      age: user.age || null,
      gender: user.gender || null,
      weight: user.weight || null,
      height: user.height || null,
    };
  }
}
