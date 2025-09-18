/**
 * Health Metrics Controller
 * 
 * This controller handles all HTTP requests related to health metrics.
 * It acts as the "front door" for the health metrics feature, receiving
 * requests from users and passing them to the service layer.
 * 
 * Key responsibilities:
 * - Validate incoming requests
 * - Extract user information from JWT tokens
 * - Call appropriate service methods
 * - Return responses to the client
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { HealthMetricsService } from './health-metrics.service';
import { CreateHealthMetricsDto } from './dto/create-health-metrics.dto';
import { UpdateHealthMetricsDto } from './dto/update-health-metrics.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

// @Controller decorator tells NestJS this class handles HTTP requests
// 'health-metrics' means all routes will start with /health-metrics
@Controller('health-metrics')
// @UseGuards ensures only authenticated users can access these endpoints
@UseGuards(JwtAuthGuard)
export class HealthMetricsController {
  constructor(private readonly healthMetricsService: HealthMetricsService) {}

  /**
   * POST /health-metrics
   * 
   * Creates new health metrics entry for a user
   * 
   * What it does:
   * 1. Receives health data from the client (weight, body fat, etc.)
   * 2. Gets the user ID from the JWT token
   * 3. Saves the data to the database
   * 4. Calculates derived metrics (BMI, TDEE, etc.)
   * 
   * Example request body:
   * {
   *   "currentWeight": 70,
   *   "bodyFatPercentage": 15,
   *   "waistCircumference": 80
   * }
   */
  @Post()
  create(@Body() createHealthMetricsDto: CreateHealthMetricsDto, @Request() req) {
    return this.healthMetricsService.create(createHealthMetricsDto, req.user.id);
  }

  /**
   * GET /health-metrics
   * 
   * Gets all health metrics entries for the authenticated user
   * 
   * What it does:
   * 1. Extracts user ID from JWT token
   * 2. Finds all health metrics for that user
   * 3. Returns them in reverse chronological order (newest first)
   * 
   * Returns: Array of health metrics objects
   */
  @Get()
  findAll(@Request() req) {
    return this.healthMetricsService.findAll(req.user.id);
  }

  /**
   * GET /health-metrics/latest
   * 
   * Gets the most recent health metrics entry for the user
   * 
   * What it does:
   * 1. Finds the newest health metrics entry
   * 2. Returns it (useful for showing current status)
   * 
   * Returns: Single health metrics object (the latest one)
   */
  @Get('latest')
  findLatest(@Request() req) {
    return this.healthMetricsService.findLatest(req.user.id);
  }

  /**
   * GET /health-metrics/calculations
   * 
   * Gets only the calculated metrics (BMI, TDEE, etc.) without raw data
   * 
   * What it does:
   * 1. Gets the latest health metrics
   * 2. Extracts only the calculated values
   * 3. Returns a clean summary of health calculations
   * 
   * Returns: Object with calculated metrics like BMI, TDEE, RMR
   */
  @Get('calculations')
  getCalculatedMetrics(@Request() req) {
    return this.healthMetricsService.getCalculatedMetrics(req.user.id);
  }

  /**
   * GET /health-metrics/:id
   * 
   * Gets a specific health metrics entry by ID
   * 
   * What it does:
   * 1. Takes an ID from the URL (like /health-metrics/123)
   * 2. Finds that specific entry for the user
   * 3. Returns it (or 404 if not found)
   * 
   * @param id - The ID of the health metrics entry to retrieve
   */
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.healthMetricsService.findOne(id, req.user.id);
  }

  /**
   * PATCH /health-metrics/:id
   * 
   * Updates an existing health metrics entry
   * 
   * What it does:
   * 1. Takes an ID and new data from the request
   * 2. Updates only the fields that were provided
   * 3. Recalculates all derived metrics
   * 4. Saves the updated entry
   * 
   * @param id - The ID of the health metrics entry to update
   * @param updateHealthMetricsDto - The new data to update with
   */
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateHealthMetricsDto: UpdateHealthMetricsDto,
    @Request() req,
  ) {
    return this.healthMetricsService.update(id, updateHealthMetricsDto, req.user.id);
  }

  /**
   * DELETE /health-metrics/:id
   * 
   * Deletes a specific health metrics entry
   * 
   * What it does:
   * 1. Takes an ID from the URL
   * 2. Finds and deletes that entry
   * 3. Returns success confirmation
   * 
   * @param id - The ID of the health metrics entry to delete
   */
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.healthMetricsService.remove(id, req.user.id);
  }
}
