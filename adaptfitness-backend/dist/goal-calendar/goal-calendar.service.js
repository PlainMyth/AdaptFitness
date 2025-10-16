"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GoalCalendarService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const goal_calendar_entity_1 = require("./goal-calendar.entity");
const workout_service_1 = require("../workout/workout.service");
let GoalCalendarService = class GoalCalendarService {
    constructor(goalCalendarRepository, workoutService) {
        this.goalCalendarRepository = goalCalendarRepository;
        this.workoutService = workoutService;
    }
    async create(createGoalCalendarDto, userId) {
        const weekStart = new Date(createGoalCalendarDto.weekStartDate);
        const weekEnd = new Date(createGoalCalendarDto.weekEndDate);
        if (weekStart >= weekEnd) {
            throw new common_1.BadRequestException('Week start date must be before week end date');
        }
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
            throw new common_1.BadRequestException('A goal for this week and type already exists');
        }
        const goal = this.goalCalendarRepository.create({
            ...createGoalCalendarDto,
            userId,
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
        });
        const savedGoal = await this.goalCalendarRepository.save(goal);
        await this.updateGoalProgress(savedGoal.id, userId);
        return savedGoal;
    }
    async findAll(userId) {
        const goals = await this.goalCalendarRepository.find({
            where: { userId },
            order: { weekStartDate: 'DESC' },
        });
        for (const goal of goals) {
            await this.updateGoalProgress(goal.id, userId);
        }
        return goals;
    }
    async findCurrentWeekGoals(userId) {
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
        for (const goal of goals) {
            await this.updateGoalProgress(goal.id, userId);
        }
        return goals;
    }
    async findOne(id, userId) {
        const goal = await this.goalCalendarRepository.findOne({
            where: { id, userId },
        });
        if (!goal) {
            throw new common_1.NotFoundException('Goal not found');
        }
        await this.updateGoalProgress(goal.id, userId);
        return goal;
    }
    async update(id, updateGoalCalendarDto, userId) {
        const goal = await this.findOne(id, userId);
        Object.assign(goal, updateGoalCalendarDto);
        if (updateGoalCalendarDto.weekStartDate || updateGoalCalendarDto.weekEndDate) {
            const weekStart = updateGoalCalendarDto.weekStartDate ? new Date(updateGoalCalendarDto.weekStartDate) : goal.weekStartDate;
            const weekEnd = updateGoalCalendarDto.weekEndDate ? new Date(updateGoalCalendarDto.weekEndDate) : goal.weekEndDate;
            if (weekStart >= weekEnd) {
                throw new common_1.BadRequestException('Week start date must be before week end date');
            }
        }
        const updatedGoal = await this.goalCalendarRepository.save(goal);
        await this.updateGoalProgress(updatedGoal.id, userId);
        return updatedGoal;
    }
    async remove(id, userId) {
        const result = await this.goalCalendarRepository.delete({ id, userId });
        if (result.affected === 0) {
            throw new common_1.NotFoundException('Goal not found');
        }
    }
    async updateGoalProgress(goalId, userId) {
        const goal = await this.goalCalendarRepository.findOne({
            where: { id: goalId, userId },
        });
        if (!goal) {
            throw new common_1.NotFoundException('Goal not found');
        }
        const workouts = await this.workoutService.findAll(userId);
        const weekWorkouts = workouts.filter(workout => {
            const workoutDate = new Date(workout.startTime);
            const startDate = new Date(goal.weekStartDate);
            const endDate = new Date(goal.weekEndDate);
            return workoutDate >= startDate && workoutDate <= endDate;
        });
        let currentValue = 0;
        let relevantWorkouts = weekWorkouts;
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
        goal.currentValue = currentValue;
        goal.completionPercentage = goal.targetValue > 0 ? (currentValue / goal.targetValue) * 100 : 0;
        goal.isCompleted = goal.completionPercentage >= 100;
        const today = new Date().toISOString().split('T')[0];
        if (!goal.progressHistory) {
            goal.progressHistory = [];
        }
        const existingProgress = goal.progressHistory.find(p => p.date === today);
        if (existingProgress) {
            existingProgress.value = currentValue;
            existingProgress.completionPercentage = goal.completionPercentage;
        }
        else {
            goal.progressHistory.push({
                date: today,
                value: currentValue,
                completionPercentage: goal.completionPercentage,
            });
        }
        goal.progressHistory = goal.progressHistory.slice(-30);
        return this.goalCalendarRepository.save(goal);
    }
    async updateAllGoalProgress(userId) {
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
    async getGoalStatistics(userId) {
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
            if (goal.isCompleted)
                stats[goal.goalType].completed++;
            stats[goal.goalType].averageCompletion += goal.completionPercentage;
            return stats;
        }, {});
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
    async getCalendarView(userId, year, month) {
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0);
        const goals = await this.goalCalendarRepository.find({
            where: {
                userId,
                weekStartDate: (0, typeorm_2.Between)(startDate, endDate),
            },
            order: { weekStartDate: 'ASC' },
        });
        const calendarData = [];
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
    getCurrentWeekDates() {
        const today = new Date();
        const dayOfWeek = today.getDay();
        const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
        const weekStart = new Date(today);
        weekStart.setDate(today.getDate() - daysToMonday);
        weekStart.setHours(0, 0, 0, 0);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 6);
        weekEnd.setHours(23, 59, 59, 999);
        return { weekStart, weekEnd };
    }
    calculateStreakDays(workouts) {
        if (workouts.length === 0)
            return 0;
        const workoutDates = new Set();
        workouts.forEach(workout => {
            const date = new Date(workout.startTime).toISOString().split('T')[0];
            workoutDates.add(date);
        });
        const sortedDates = Array.from(workoutDates).sort();
        let streak = 0;
        let currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0);
        for (let i = sortedDates.length - 1; i >= 0; i--) {
            const workoutDate = new Date(sortedDates[i]);
            const daysDiff = Math.floor((currentDate.getTime() - workoutDate.getTime()) / (1000 * 60 * 60 * 24));
            if (daysDiff === streak) {
                streak++;
                currentDate.setDate(currentDate.getDate() - 1);
            }
            else {
                break;
            }
        }
        return streak;
    }
};
exports.GoalCalendarService = GoalCalendarService;
exports.GoalCalendarService = GoalCalendarService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(goal_calendar_entity_1.GoalCalendar)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        workout_service_1.WorkoutService])
], GoalCalendarService);
//# sourceMappingURL=goal-calendar.service.js.map