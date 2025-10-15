import { IsString, IsOptional, IsNumber, IsDateString, IsPositive, Min, MaxLength } from 'class-validator';

/**
 * Create Workout DTO
 *
 * This DTO defines the data structure for creating new workout entries.
 * Uses class-validator decorators for automatic validation.
 *
 * Key responsibilities:
 * - Define workout creation data structure
 * - Validate input data with decorators
 * - Provide type safety for workout creation
 * - Serve as a contract for API consumers
 */
export class CreateWorkoutDto {
  @IsString()
  @MaxLength(200)
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  description?: string;

  @IsDateString()
  startTime: Date;

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
  userId?: string; // Will be set by controller from JWT
}