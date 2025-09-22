import { Controller, Get, Post, Put, Delete, Body, Param, Request, UseGuards, Query } from '@nestjs/common';
import { WorkoutService } from './workout.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';

/**
 * Workout Controller
 *
 * This controller handles all HTTP requests related to workout management.
 * It provides endpoints for creating, reading, updating, and deleting workouts,
 * as well as streak tracking functionality.
 *
 * Key responsibilities:
 * - Handle workout CRUD operations
 * - Manage workout streak calculations
 * - Provide timezone-aware streak tracking
 * - Validate user authentication
 */
@Controller('workouts')
@UseGuards(JwtAuthGuard)
export class WorkoutController {
  constructor(private readonly workoutService: WorkoutService) {}

  @Post()
  async create(@Request() req, @Body() createWorkoutDto: CreateWorkoutDto) {
    createWorkoutDto.userId = req.user.id;
    return this.workoutService.create(createWorkoutDto);
  }

  @Get()
  async findAll(@Request() req) {
    return this.workoutService.findAll(req.user.id);
  }

  @Get('streak/current')
  async getCurrentStreak(@Request() req, @Query('tz') timeZone?: string) {
    return this.workoutService.getCurrentStreakInTimeZone(req.user.id, timeZone);
  }

  @Get(':id')
  async findOne(@Request() req, @Param('id') id: string) {
    return this.workoutService.findOne(id);
  }

  @Put(':id')
  async update(@Request() req, @Param('id') id: string, @Body() updateData: UpdateWorkoutDto) {
    return this.workoutService.update(id, updateData);
  }

  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    await this.workoutService.remove(id);
    return { message: 'Workout deleted successfully' };
  }
}