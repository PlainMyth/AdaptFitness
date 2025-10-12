import { Repository } from 'typeorm';
import { GoalCalendar } from './goal-calendar.entity';
import { CreateGoalCalendarDto } from './dto/create-goal-calendar.dto';
import { UpdateGoalCalendarDto } from './dto/update-goal-calendar.dto';
import { WorkoutService } from '../workout/workout.service';
export declare class GoalCalendarService {
    private goalCalendarRepository;
    private workoutService;
    constructor(goalCalendarRepository: Repository<GoalCalendar>, workoutService: WorkoutService);
    create(createGoalCalendarDto: CreateGoalCalendarDto, userId: string): Promise<GoalCalendar>;
    findAll(userId: string): Promise<GoalCalendar[]>;
    findCurrentWeekGoals(userId: string): Promise<GoalCalendar[]>;
    findOne(id: string, userId: string): Promise<GoalCalendar>;
    update(id: string, updateGoalCalendarDto: UpdateGoalCalendarDto, userId: string): Promise<GoalCalendar>;
    remove(id: string, userId: string): Promise<void>;
    updateGoalProgress(goalId: string, userId: string): Promise<GoalCalendar>;
    updateAllGoalProgress(userId: string): Promise<GoalCalendar[]>;
    getGoalStatistics(userId: string): Promise<any>;
    getCalendarView(userId: string, year: number, month: number): Promise<any>;
    private getCurrentWeekDates;
    private calculateStreakDays;
}
