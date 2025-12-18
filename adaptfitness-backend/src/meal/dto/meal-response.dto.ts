import { Expose, Transform } from 'class-transformer';
import { Meal } from '../meal.entity';

/**
 * Meal Response DTO
 *
 * This DTO transforms the Meal entity for API responses.
 * It ensures proper serialization of dates and decimal values.
 */
export class MealResponseDto {
  @Expose()
  id: string;

  @Expose()
  userId: string;

  @Expose()
  name: string;

  @Expose()
  description?: string;

  @Expose()
  @Transform(({ value }) => {
    if (value instanceof Date) {
      return value.toISOString();
    }
    return value;
  })
  mealTime: string;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalCalories: number;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalProtein: number;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalCarbs: number;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalFat: number;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalFiber?: number;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalSugar?: number;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  totalSodium?: number;

  @Expose()
  mealType?: string;

  @Expose()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return value ?? 0;
  })
  servingSize?: number;

  @Expose()
  servingUnit?: string;

  @Expose()
  @Transform(({ value }) => {
    if (value instanceof Date) {
      return value.toISOString();
    }
    return value;
  })
  createdAt?: string;

  @Expose()
  @Transform(({ value }) => {
    if (value instanceof Date) {
      return value.toISOString();
    }
    return value;
  })
  updatedAt?: string;
}

