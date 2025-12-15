import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { AiWorkoutPlanGeneratorController } from './ai-workout-plan-generator.controller';
import { AiWorkoutPlanGeneratorService } from './ai-workout-plan-generator.service';
import { GeminiAiService } from './gemini-ai.service';
import { ExerciseDbService } from './exercise-db.service';
import { UserModule } from '../user/user.module';

@Module({
  imports: [
    HttpModule,    // For ExerciseDB API calls
    UserModule,    // For user profile access
  ],
  providers: [
    AiWorkoutPlanGeneratorService,
    GeminiAiService,
    ExerciseDbService,
  ],
  controllers: [AiWorkoutPlanGeneratorController],
  exports: [AiWorkoutPlanGeneratorService],
})
export class AiWorkoutPlanGeneratorModule {}
