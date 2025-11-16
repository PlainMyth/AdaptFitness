import { Controller, Get, Post, Put, Delete, Body, Param, Request, UseGuards, Query, ValidationPipe } from '@nestjs/common';
import { MealService } from './meal.service';
import { FoodService } from './food.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { FoodSearchDto } from './dto/food-search.dto';

/**
 * Meal Controller
 *
 * This controller handles all HTTP requests related to meal management.
 * It provides endpoints for creating, reading, updating, and deleting meals,
 * as well as streak tracking functionality.
 *
 * Key responsibilities:
 * - Handle meal CRUD operations
 * - Manage meal streak calculations
 * - Provide timezone-aware streak tracking
 * - Validate user authentication
 */
@Controller('meals')
@UseGuards(JwtAuthGuard)
export class MealController {
  constructor(
    private readonly mealService: MealService,
    private readonly foodService: FoodService,
  ) {}

  @Post()
  async create(@Request() req, @Body() createMealDto: CreateMealDto) {
    createMealDto.userId = req.user.id;
    return this.mealService.create(createMealDto);
  }

  @Get()
  async findAll(@Request() req) {
    return this.mealService.findAll(req.user.id);
  }

  @Get('streak/current')
  async getCurrentStreak(@Request() req, @Query('tz') timeZone?: string) {
    return this.mealService.getCurrentStreakInTimeZone(req.user.id, timeZone);
  }

  /**
   * Search for foods using OpenFoodFacts API
   * GET /meals/foods/search?query=apple&page=1&pageSize=20
   * Note: Must come before @Get(':id') to avoid route conflicts
   */
  @Get('foods/search')
  async searchFoods(
    @Query(new ValidationPipe({ transform: true, transformOptions: { enableImplicitConversion: true } })) searchDto: FoodSearchDto,
  ) {
    return this.foodService.searchFoods(searchDto);
  }

  /**
   * Get food by barcode using OpenFoodFacts API
   * GET /meals/foods/barcode/:barcode
   * Note: Must come before @Get(':id') to avoid route conflicts
   */
  @Get('foods/barcode/:barcode')
  async getFoodByBarcode(@Param('barcode') barcode: string) {
    return this.foodService.getFoodByBarcode(barcode);
  }

  @Get(':id')
  async findOne(@Request() req, @Param('id') id: string) {
    return this.mealService.findOne(id);
  }

  @Put(':id')
  async update(@Request() req, @Param('id') id: string, @Body() updateData: UpdateMealDto) {
    return this.mealService.update(id, updateData);
  }

  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    await this.mealService.remove(id);
    return { message: 'Meal deleted successfully' };
  }
}