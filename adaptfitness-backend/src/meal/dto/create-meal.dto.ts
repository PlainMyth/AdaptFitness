import { IsString, IsOptional, IsNumber, IsDateString, IsPositive, MaxLength, Min, IsEnum } from 'class-validator';

/**
 * Create Meal DTO
 *
 * This DTO defines the data structure for creating new meal entries.
 * Uses class-validator decorators for automatic validation.
 *
 * Key responsibilities:
 * - Define meal creation data structure
 * - Validate input data with decorators
 * - Provide type safety for meal creation
 * - Serve as a contract for API consumers
 */
export class CreateMealDto {
  @IsString()
  @MaxLength(200)
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  description?: string;

  @IsDateString()
  mealTime: Date;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalCalories?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalProtein?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalCarbs?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalFat?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalFiber?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalSugar?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  totalSodium?: number;

  @IsString()
  @IsOptional()
  @IsEnum(['breakfast', 'lunch', 'dinner', 'snack', 'other'])
  mealType?: string;

  @IsNumber()
  @IsOptional()
  @Min(0)
  servingSize?: number;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  servingUnit?: string;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  notes?: string;

  @IsString()
  @IsOptional()
  userId?: string; // Will be set by controller from JWT
}