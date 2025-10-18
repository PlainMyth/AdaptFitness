import { IsString, IsOptional, IsNumber, IsDateString, IsPositive, MaxLength } from 'class-validator';

/**
 * Update Meal DTO
 *
 * This DTO defines the data structure for updating existing meal entries.
 * All fields are optional to allow partial updates.
 * Uses class-validator decorators for automatic validation.
 *
 * Key responsibilities:
 * - Define meal update data structure
 * - Validate input data with decorators
 * - Allow partial updates of meal data
 * - Provide type safety for meal updates
 */
export class UpdateMealDto {
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
  mealTime?: Date;

  @IsNumber()
  @IsOptional()
  @IsPositive()
  totalCalories?: number;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  notes?: string;

  @IsString()
  @IsOptional()
  userId?: string;
}