import { IsEnum, IsNumber, IsString, IsOptional, IsDateString, IsBoolean, Min, Max } from 'class-validator';

export class CreateGoalCalendarDto {
  @IsDateString()
  weekStartDate: string;

  @IsDateString()
  weekEndDate: string;

  @IsEnum(['workouts_count', 'total_duration', 'total_calories', 'total_sets', 'total_reps', 'total_weight', 'streak_days'])
  goalType: string;

  @IsNumber()
  @Min(0.01)
  targetValue: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(['strength', 'cardio', 'flexibility', 'sports', 'other'])
  workoutType?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
