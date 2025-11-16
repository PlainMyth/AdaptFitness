import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Food Search DTO
 *
 * This DTO defines the structure for searching foods using OpenFoodFacts API.
 */
export class FoodSearchDto {
  @IsString()
  query: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(50)
  pageSize?: number = 20;
}

/**
 * Food Item Response DTO
 *
 * This DTO defines the structure for food items returned from OpenFoodFacts API.
 */
export class FoodItemDto {
  code: string; // Barcode
  product_name: string;
  product_name_en?: string;
  brands?: string;
  categories?: string;
  image_url?: string;
  nutriments?: {
    energy_kcal_100g?: number;
    proteins_100g?: number;
    carbohydrates_100g?: number;
    fat_100g?: number;
    fiber_100g?: number;
    sugars_100g?: number;
    sodium_100g?: number;
  };
  serving_size?: string;
  serving_quantity?: number;
}

/**
 * Food Search Response DTO
 *
 * This DTO defines the structure for the food search response from OpenFoodFacts API.
 */
export class FoodSearchResponseDto {
  count: number;
  page: number;
  pageCount: number;
  products: FoodItemDto[];
}

/**
 * Simplified Food Item DTO
 *
 * This DTO provides a simplified structure mapped from OpenFoodFacts for our API response.
 */
export class SimplifiedFoodItemDto {
  id: string; // Barcode
  name: string;
  brand?: string;
  category?: string;
  imageUrl?: string;
  servingSize?: number;
  servingUnit?: string;
  nutritionPer100g: {
    calories: number;
    protein: number; // grams
    carbs: number; // grams
    fat: number; // grams
    fiber?: number; // grams
    sugar?: number; // grams
    sodium?: number; // mg
  };
  nutritionPerServing?: {
    calories: number;
    protein: number;
    carbs: number;
    fat: number;
    fiber?: number;
    sugar?: number;
    sodium?: number;
  };
}

