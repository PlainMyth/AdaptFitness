/**
 * Goal Calendar Controller
 *
 * This controller handles all HTTP requests related to goal calendar functionality.
 * It provides endpoints for managing weekly fitness goals, tracking progress,
 * and viewing calendar-based goal visualization.
 *
 * Key responsibilities:
 * - Handle goal calendar CRUD operations
 * - Provide progress tracking endpoints
 * - Serve calendar view data
 * - Integrate with workout data for progress calculation
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
  Query,
  ParseIntPipe,
} from '@nestjs/common';
import { GoalCalendarService } from './goal-calendar.service';
import { CreateGoalCalendarDto } from './dto/create-goal-calendar.dto';
import { UpdateGoalCalendarDto } from './dto/update-goal-calendar.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('goal-calendar')
@UseGuards(JwtAuthGuard)
export class GoalCalendarController {
  constructor(private readonly goalCalendarService: GoalCalendarService) {}

  /**
   * POST /goal-calendar
   * 
   * Creates a new weekly fitness goal for the authenticated user
   * 
   * Example request body:
   * {
   *   "weekStartDate": "2024-01-15",
   *   "weekEndDate": "2024-01-21",
   *   "goalType": "workouts_count",
   *   "targetValue": 5,
   *   "description": "Complete 5 workouts this week",
   *   "workoutType": "strength"
   * }
   */
  @Post()
  create(@Body() createGoalCalendarDto: CreateGoalCalendarDto, @Request() req) {
    return this.goalCalendarService.create(createGoalCalendarDto, req.user.id);
  }

  /**
   * GET /goal-calendar
   * 
   * Gets all fitness goals for the authenticated user, ordered by week (newest first)
   * 
   * Returns: Array of goal objects with current progress calculated
   */
  @Get()
  findAll(@Request() req) {
    return this.goalCalendarService.findAll(req.user.id);
  }

  /**
   * GET /goal-calendar/current-week
   * 
   * Gets all active goals for the current week
   * 
   * Returns: Array of current week goals with up-to-date progress
   */
  @Get('current-week')
  findCurrentWeekGoals(@Request() req) {
    return this.goalCalendarService.findCurrentWeekGoals(req.user.id);
  }

  /**
   * GET /goal-calendar/statistics
   * 
   * Gets comprehensive goal statistics for the user
   * 
   * Returns: Object with goal completion rates, averages, and type-specific stats
   */
  @Get('statistics')
  getStatistics(@Request() req) {
    return this.goalCalendarService.getGoalStatistics(req.user.id);
  }

  /**
   * GET /goal-calendar/calendar-view
   * 
   * Gets calendar view data for a specific month
   * 
   * Query parameters:
   * - year: The year (e.g., 2024)
   * - month: The month (1-12)
   * 
   * Example: GET /goal-calendar/calendar-view?year=2024&month=1
   */
  @Get('calendar-view')
  getCalendarView(
    @Request() req,
    @Query('year', ParseIntPipe) year: number,
    @Query('month', ParseIntPipe) month: number,
  ) {
    return this.goalCalendarService.getCalendarView(req.user.id, year, month);
  }

  /**
   * POST /goal-calendar/:id/update-progress
   * 
   * Manually updates the progress of a specific goal based on current workout data
   * 
   * @param id - The ID of the goal to update
   */
  @Post(':id/update-progress')
  updateProgress(@Param('id') id: string, @Request() req) {
    return this.goalCalendarService.updateGoalProgress(id, req.user.id);
  }

  /**
   * POST /goal-calendar/update-all-progress
   * 
   * Updates progress for all active goals based on current workout data
   * Useful for batch updates after workout logging
   */
  @Post('update-all-progress')
  updateAllProgress(@Request() req) {
    return this.goalCalendarService.updateAllGoalProgress(req.user.id);
  }

  /**
   * GET /goal-calendar/:id
   * 
   * Gets a specific goal by ID with current progress
   * 
   * @param id - The ID of the goal to retrieve
   */
  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.goalCalendarService.findOne(id, req.user.id);
  }

  /**
   * PATCH /goal-calendar/:id
   * 
   * Updates an existing goal
   * 
   * @param id - The ID of the goal to update
   * @param updateGoalCalendarDto - The updated goal data
   */
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateGoalCalendarDto: UpdateGoalCalendarDto,
    @Request() req,
  ) {
    return this.goalCalendarService.update(id, updateGoalCalendarDto, req.user.id);
  }

  /**
   * DELETE /goal-calendar/:id
   * 
   * Deletes a specific goal
   * 
   * @param id - The ID of the goal to delete
   */
  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.goalCalendarService.remove(id, req.user.id);
  }
}
