import { Injectable, BadRequestException, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { FoodSearchDto, FoodSearchResponseDto, SimplifiedFoodItemDto, FoodItemDto } from './dto/food-search.dto';

/**
 * Food Service
 *
 * This service handles integration with the OpenFoodFacts API to search for
 * food products and retrieve their nutritional information.
 *
 * Key responsibilities:
 * - Search for food products by name
 * - Retrieve food details by barcode
 * - Map OpenFoodFacts data to our simplified format
 * - Handle API errors and rate limiting
 */
@Injectable()
export class FoodService {
  private readonly OPENFOODFACTS_BASE_URL = 'https://world.openfoodfacts.org';
  private readonly OPENFOODFACTS_API_URL = `${this.OPENFOODFACTS_BASE_URL}/api/v0`;
  private readonly OPENFOODFACTS_SEARCH_URL = `${this.OPENFOODFACTS_BASE_URL}/cgi/search.pl`;

  constructor(private readonly httpService: HttpService) {}

  /**
   * Search for food products by name
   * @param searchDto - Search parameters (query, page, pageSize)
   * @returns Array of simplified food items
   */
  async searchFoods(searchDto: FoodSearchDto): Promise<{
    foods: SimplifiedFoodItemDto[];
    totalCount: number;
    page: number;
    pageSize: number;
    totalPages: number;
  }> {
    try {
      const { query, page = 1, pageSize = 20 } = searchDto;

      if (!query || query.trim().length === 0) {
        throw new BadRequestException('Search query is required');
      }

      if (query.length < 2) {
        throw new BadRequestException('Search query must be at least 2 characters long');
      }

      const url = this.OPENFOODFACTS_SEARCH_URL;
      const params = {
        search_terms: query.trim(),
        search_simple: '1',
        action: 'process',
        json: '1',
        page_size: pageSize.toString(),
        page: page.toString(),
        fields: 'code,product_name,product_name_en,brands,categories,image_url,nutriments,serving_size,serving_quantity',
      };

      const response = await firstValueFrom(
        this.httpService.get<FoodSearchResponseDto>(url, { params })
      );

      if (!response.data || !response.data.products) {
        return {
          foods: [],
          totalCount: 0,
          page,
          pageSize,
          totalPages: 0,
        };
      }

      const foods = response.data.products
        .filter(product => product.product_name && product.nutriments)
        .map(product => this.mapToSimplifiedFoodItem(product))
        .filter(food => food !== null);

      return {
        foods,
        totalCount: response.data.count || foods.length,
        page,
        pageSize,
        totalPages: Math.ceil((response.data.count || foods.length) / pageSize),
      };
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }

      console.error('Error searching foods from OpenFoodFacts:', error);
      throw new HttpException(
        'Failed to search foods. Please try again later.',
        HttpStatus.SERVICE_UNAVAILABLE
      );
    }
  }

  /**
   * Get food product by barcode
   * @param barcode - Product barcode
   * @returns Simplified food item
   */
  async getFoodByBarcode(barcode: string): Promise<SimplifiedFoodItemDto> {
    try {
      if (!barcode || barcode.trim().length === 0) {
        throw new BadRequestException('Barcode is required');
      }

      const url = `${this.OPENFOODFACTS_API_URL}/product/${barcode.trim()}.json`;

      const response = await firstValueFrom(
        this.httpService.get<{ status: number; product?: FoodItemDto }>(url)
      );

      if (response.data.status === 0 || !response.data.product) {
        throw new HttpException(
          `Food product with barcode ${barcode} not found`,
          HttpStatus.NOT_FOUND
        );
      }

      const product = response.data.product;

      if (!product.product_name || !product.nutriments) {
        throw new HttpException(
          `Food product with barcode ${barcode} has incomplete data`,
          HttpStatus.BAD_REQUEST
        );
      }

      const simplified = this.mapToSimplifiedFoodItem(product);

      if (!simplified) {
        throw new HttpException(
          `Failed to parse food product data for barcode ${barcode}`,
          HttpStatus.INTERNAL_SERVER_ERROR
        );
      }

      return simplified;
    } catch (error) {
      if (error instanceof BadRequestException || error instanceof HttpException) {
        throw error;
      }

      console.error('Error fetching food by barcode from OpenFoodFacts:', error);
      throw new HttpException(
        'Failed to fetch food product. Please try again later.',
        HttpStatus.SERVICE_UNAVAILABLE
      );
    }
  }

  /**
   * Map OpenFoodFacts product data to simplified format
   * @param product - OpenFoodFacts product data
   * @returns Simplified food item or null if invalid
   */
  private mapToSimplifiedFoodItem(product: FoodItemDto): SimplifiedFoodItemDto | null {
    try {
      if (!product.product_name || !product.nutriments) {
        return null;
      }

      const nutriments = product.nutriments;
      
      // Get nutrition per 100g
      const nutritionPer100g = {
        calories: nutriments.energy_kcal_100g || 0,
        protein: nutriments.proteins_100g || 0,
        carbs: nutriments.carbohydrates_100g || 0,
        fat: nutriments.fat_100g || 0,
        fiber: nutriments.fiber_100g,
        sugar: nutriments.sugars_100g,
        sodium: nutriments.sodium_100g ? nutriments.sodium_100g * 1000 : undefined, // Convert to mg
      };

      // Calculate nutrition per serving if serving size is available
      let nutritionPerServing: SimplifiedFoodItemDto['nutritionPerServing'] | undefined;
      if (product.serving_quantity && product.serving_quantity > 0) {
        const servingMultiplier = product.serving_quantity / 100; // Convert to per serving
        nutritionPerServing = {
          calories: Math.round(nutritionPer100g.calories * servingMultiplier),
          protein: Number((nutritionPer100g.protein * servingMultiplier).toFixed(1)),
          carbs: Number((nutritionPer100g.carbs * servingMultiplier).toFixed(1)),
          fat: Number((nutritionPer100g.fat * servingMultiplier).toFixed(1)),
          fiber: nutritionPer100g.fiber ? Number((nutritionPer100g.fiber * servingMultiplier).toFixed(1)) : undefined,
          sugar: nutritionPer100g.sugar ? Number((nutritionPer100g.sugar * servingMultiplier).toFixed(1)) : undefined,
          sodium: nutritionPer100g.sodium ? Math.round(nutritionPer100g.sodium * servingMultiplier) : undefined,
        };
      }

      return {
        id: product.code,
        name: product.product_name_en || product.product_name,
        brand: product.brands,
        category: product.categories?.split(',')[0]?.trim(),
        imageUrl: product.image_url,
        servingSize: product.serving_quantity,
        servingUnit: product.serving_size || 'g',
        nutritionPer100g,
        nutritionPerServing,
      };
    } catch (error) {
      console.error('Error mapping food item:', error);
      return null;
    }
  }
}

