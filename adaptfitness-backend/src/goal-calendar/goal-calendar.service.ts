/**
 * Goal Calendar Service
 *
 * This service handles all goal calendar-related business logic including CRUD operations,
 * progress tracking, workout integration, and goal completion calculations.
 *
 * Key responsibilities:
 * - Handle goal calendar business logic
 * - Calculate progress based on workout data
 * - Manage weekly goal tracking and completion
 * - Provide calendar-based goal visualization
 * - Integrate with workout service for progress calculation
 */

import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { GoalCalendar } from './goal-calendar.entity';
import { CreateGoalCalendarDto } from './dto/create-goal-calendar.dto';
import { UpdateGoalCalendarDto } from './dto/update-goal-calendar.dto';
import { WorkoutService } from '../workout/workout.service';

@Injectable()
export class GoalCalendarService {
  constructor(
    @InjectRepository(GoalCalendar)
    private goalCalendarRepository: Repository<GoalCalendar>,
    private workoutService: WorkoutService,
  ) {}

  async create(createGoalCalendarDto: CreateGoalCalendarDto, userId: string): Promise<GoalCalendar> {
    // Validate that week start and end dates are valid
    const weekStart = new Date(createGoalCalendarDto.weekStartDate);
    const weekEnd = new Date(createGoalCalendarDto.weekEndDate);
    
    if (weekStart >= weekEnd) {
      throw new BadRequestException('Week start date must be before week end date');
    }

    // Check if user already has a goal for this week and type
    const existingGoal = await this.goalCalendarRepository.findOne({
      where: {
        userId,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        goalType: createGoalCalendarDto.goalType,
        workoutType: createGoalCalendarDto.workoutType || null,
      },
    });

    if (existingGoal) {
      throw new BadRequestException('A goal for this week and type already exists');
    }

    const goal = this.goalCalendarRepository.create({
      ...createGoalCalendarDto,
      userId,
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
    });

    const savedGoal = await this.goalCalendarRepository.save(goal);
    
    // Calculate initial progress
    await this.updateGoalProgress(savedGoal.id, userId);
    
    return savedGoal;
  }

  async findAll(userId: string): Promise<GoalCalendar[]> {
    const goals = await this.goalCalendarRepository.find({
      where: { userId },
      order: { weekStartDate: 'DESC' },
    });

    // Update progress for all goals
    for (const goal of goals) {
      await this.updateGoalProgress(goal.id, userId);
    }

    return goals;
  }

  async findCurrentWeekGoals(userId: string): Promise<GoalCalendar[]> {
    const { weekStart, weekEnd } = this.getCurrentWeekDates();
    
    const goals = await this.goalCalendarRepository.find({
      where: {
        userId,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        isActive: true,
      },
      order: { createdAt: 'ASC' },
    });

    // Update progress for current week goals
    for (const goal of goals) {
      await this.updateGoalProgress(goal.id, userId);
    }

    return goals;
  }

  async findOne(id: string, userId: string): Promise<GoalCalendar> {
    const goal = await this.goalCalendarRepository.findOne({
      where: { id, userId },
    });
    
    if (!goal) {
      throw new NotFoundException('Goal not found');
    }
    
    // Update progress before returning
    await this.updateGoalProgress(goal.id, userId);
    
    return goal;
  }

  async update(id: string, updateGoalCalendarDto: UpdateGoalCalendarDto, userId: string): Promise<GoalCalendar> {
    const goal = await this.findOne(id, userId);
    
    Object.assign(goal, updateGoalCalendarDto);
    
    // If dates are being updated, validate them
    if (updateGoalCalendarDto.weekStartDate || updateGoalCalendarDto.weekEndDate) {
      const weekStart = updateGoalCalendarDto.weekStartDate ? new Date(updateGoalCalendarDto.weekStartDate) : goal.weekStartDate;
      const weekEnd = updateGoalCalendarDto.weekEndDate ? new Date(updateGoalCalendarDto.weekEndDate) : goal.weekEndDate;
      
      if (weekStart >= weekEnd) {
        throw new BadRequestException('Week start date must be before week end date');
      }
    }

    const updatedGoal = await this.goalCalendarRepository.save(goal);
    
    // Recalculate progress after update
    await this.updateGoalProgress(updatedGoal.id, userId);
    
    return updatedGoal;
  }

  async remove(id: string, userId: string): Promise<void> {
    const result = await this.goalCalendarRepository.delete({ id, userId });
    if (result.affected === 0) {
      throw new NotFoundException('Goal not found');
    }
  }

  /**
   * Updates the progress of a specific goal based on actual workout data
   */
  async updateGoalProgress(goalId: string, userId: string): Promise<GoalCalendar> {
    const goal = await this.goalCalendarRepository.findOne({
      where: { id: goalId, userId },
    });

    if (!goal) {
      throw new NotFoundException('Goal not found');
    }

    // Get workouts for the goal's week
    const workouts = await this.workoutService.findAll(userId);
    const weekWorkouts = workouts.filter(workout => {
      const workoutDate = new Date(workout.startTime);
      const startDate = new Date(goal.weekStartDate);
      const endDate = new Date(goal.weekEndDate);
      return workoutDate >= startDate && workoutDate <= endDate;
    });

    // Calculate current value based on goal type
    let currentValue = 0;
    let relevantWorkouts = weekWorkouts;

    // Filter by workout type if specified
    if (goal.workoutType) {
      relevantWorkouts = weekWorkouts.filter(workout => workout.workoutType === goal.workoutType);
    }

    switch (goal.goalType) {
      case 'workouts_count':
        currentValue = relevantWorkouts.length;
        break;
      case 'total_duration':
        currentValue = relevantWorkouts.reduce((sum, workout) => sum + (workout.totalDuration || 0), 0);
        break;
      case 'total_calories':
        currentValue = relevantWorkouts.reduce((sum, workout) => sum + (workout.totalCaloriesBurned || 0), 0);
        break;
      case 'total_sets':
        currentValue = relevantWorkouts.reduce((sum, workout) => sum + (workout.totalSets || 0), 0);
        break;
      case 'total_reps':
        currentValue = relevantWorkouts.reduce((sum, workout) => sum + (workout.totalReps || 0), 0);
        break;
      case 'total_weight':
        currentValue = relevantWorkouts.reduce((sum, workout) => sum + (workout.totalWeight || 0), 0);
        break;
      case 'streak_days':
        currentValue = this.calculateStreakDays(relevantWorkouts);
        break;
    }

    // Update goal with new progress
    goal.currentValue = currentValue;
    goal.completionPercentage = goal.targetValue > 0 ? (currentValue / goal.targetValue) * 100 : 0;
    goal.isCompleted = goal.completionPercentage >= 100;

    // Update progress history
    const today = new Date().toISOString().split('T')[0];
    if (!goal.progressHistory) {
      goal.progressHistory = [];
    }

    // Add today's progress snapshot
    const existingProgress = goal.progressHistory.find(p => p.date === today);
    if (existingProgress) {
      existingProgress.value = currentValue;
      existingProgress.completionPercentage = goal.completionPercentage;
    } else {
      goal.progressHistory.push({
        date: today,
        value: currentValue,
        completionPercentage: goal.completionPercentage,
      });
    }

    // Keep only last 30 days of progress history
    goal.progressHistory = goal.progressHistory.slice(-30);

    return this.goalCalendarRepository.save(goal);
  }

  /**
   * Updates progress for all active goals of a user
   */
  async updateAllGoalProgress(userId: string): Promise<GoalCalendar[]> {
    const activeGoals = await this.goalCalendarRepository.find({
      where: { userId, isActive: true },
    });

    const updatedGoals = [];
    for (const goal of activeGoals) {
      const updatedGoal = await this.updateGoalProgress(goal.id, userId);
      updatedGoals.push(updatedGoal);
    }

    return updatedGoals;
  }

  /**
   * Gets goal statistics for a user
   */
  async getGoalStatistics(userId: string): Promise<any> {
    const goals = await this.findAll(userId);
    
    const totalGoals = goals.length;
    const completedGoals = goals.filter(g => g.isCompleted).length;
    const activeGoals = goals.filter(g => g.isActive && g.isCurrentWeek).length;
    
    const averageCompletion = goals.length > 0 
      ? goals.reduce((sum, g) => sum + g.completionPercentage, 0) / goals.length 
      : 0;

    const goalTypeStats = goals.reduce((stats, goal) => {
      if (!stats[goal.goalType]) {
        stats[goal.goalType] = { total: 0, completed: 0, averageCompletion: 0 };
      }
      stats[goal.goalType].total++;
      if (goal.isCompleted) stats[goal.goalType].completed++;
      stats[goal.goalType].averageCompletion += goal.completionPercentage;
      return stats;
    }, {});

    // Calculate average completion for each goal type
    Object.keys(goalTypeStats).forEach(type => {
      if (goalTypeStats[type].total > 0) {
        goalTypeStats[type].averageCompletion /= goalTypeStats[type].total;
      }
    });

    return {
      totalGoals,
      completedGoals,
      activeGoals,
      completionRate: totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0,
      averageCompletion,
      goalTypeStats,
    };
  }

  /**
   * Gets calendar view data for a specific month
   */
  async getCalendarView(userId: string, year: number, month: number): Promise<any> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    
    const goals = await this.goalCalendarRepository.find({
      where: {
        userId,
        weekStartDate: Between(startDate, endDate),
      },
      order: { weekStartDate: 'ASC' },
    });

    const calendarData = [];
    
    // Group goals by week
    const weeklyGoals = {};
    goals.forEach(goal => {
      const weekKey = goal.weekIdentifier;
      if (!weeklyGoals[weekKey]) {
        weeklyGoals[weekKey] = [];
      }
      weeklyGoals[weekKey].push(goal);
    });

    return {
      month,
      year,
      weeklyGoals,
      totalWeeks: Object.keys(weeklyGoals).length,
      totalGoals: goals.length,
    };
  }

  private getCurrentWeekDates(): { weekStart: Date; weekEnd: Date } {
    const today = new Date();
    const dayOfWeek = today.getDay();
    const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Handle Sunday as day 0
    
    const weekStart = new Date(today);
    weekStart.setDate(today.getDate() - daysToMonday);
    weekStart.setHours(0, 0, 0, 0);
    
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 6);
    weekEnd.setHours(23, 59, 59, 999);
    
    return { weekStart, weekEnd };
  }

  private calculateStreakDays(workouts: any[]): number {
    if (workouts.length === 0) return 0;
    
    // Get unique dates from workouts
    const workoutDates = new Set<string>();
    workouts.forEach(workout => {
      const date = new Date(workout.startTime).toISOString().split('T')[0];
      workoutDates.add(date);
    });
    
    // Convert to sorted array
    const sortedDates = Array.from(workoutDates).sort();
    
    // Calculate consecutive days from the end
    let streak = 0;
    let currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);
    
    for (let i = sortedDates.length - 1; i >= 0; i--) {
      const workoutDate = new Date(sortedDates[i]);
      const daysDiff = Math.floor((currentDate.getTime() - workoutDate.getTime()) / (1000 * 60 * 60 * 24));
      
      if (daysDiff === streak) {
        streak++;
        currentDate.setDate(currentDate.getDate() - 1);
      } else {
        break;
      }
    }
    
    return streak;
  }
}
