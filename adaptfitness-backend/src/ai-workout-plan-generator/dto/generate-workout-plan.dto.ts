import { IsString, IsInt, IsEnum, Min, Max } from 'class-validator';

export class GenerateWorkoutPlanDto {
  @IsString()
  userGoal: string;

  @IsString()
  @IsEnum(['beginner', 'intermediate', 'advanced'])
  experienceLevel: string;

  @IsInt()
  @Min(3)
  @Max(7)
  daysPerWeek: number;
}
