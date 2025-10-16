import { IsString, IsOptional, IsNumber, IsDateString, IsPositive, Min, MaxLength } from 'class-validator';

/**
 * Update Workout DTO
 *
 * This DTO defines the data structure for updating existing workout entries.
 * All fields are optional to allow partial updates.
 * Uses class-validator decorators for automatic validation.
 *
 * Key responsibilities:
 * - Define workout update data structure
 * - Validate input data with decorators
 * - Allow partial updates of workout data
 * - Provide type safety for workout updates
 */
export class UpdateWorkoutDto {
  @IsString()
  @IsOptional()
  @MaxLength(200)
  name?: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  description?: string;

  @IsDateString()
  @IsOptional()
  startTime?: Date;

  @IsDateString()
  @IsOptional()
  endTime?: Date;

  @IsNumber()
  @IsOptional()
  @IsPositive()
  totalCaloriesBurned?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalDuration?: number; // in minutes

  @IsString()
  @IsOptional()
  @MaxLength(500)
  notes?: string;

  @IsString()
  @IsOptional()
  userId?: string;
}