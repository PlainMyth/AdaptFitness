import { GoalCalendarService } from './goal-calendar.service';
import { CreateGoalCalendarDto } from './dto/create-goal-calendar.dto';
import { UpdateGoalCalendarDto } from './dto/update-goal-calendar.dto';
export declare class GoalCalendarController {
    private readonly goalCalendarService;
    constructor(goalCalendarService: GoalCalendarService);
    create(createGoalCalendarDto: CreateGoalCalendarDto, req: any): Promise<import("./goal-calendar.entity").GoalCalendar>;
    findAll(req: any): Promise<import("./goal-calendar.entity").GoalCalendar[]>;
    findCurrentWeekGoals(req: any): Promise<import("./goal-calendar.entity").GoalCalendar[]>;
    getStatistics(req: any): Promise<any>;
    getCalendarView(req: any, year: number, month: number): Promise<any>;
    updateProgress(id: string, req: any): Promise<import("./goal-calendar.entity").GoalCalendar>;
    updateAllProgress(req: any): Promise<import("./goal-calendar.entity").GoalCalendar[]>;
    findOne(id: string, req: any): Promise<import("./goal-calendar.entity").GoalCalendar>;
    update(id: string, updateGoalCalendarDto: UpdateGoalCalendarDto, req: any): Promise<import("./goal-calendar.entity").GoalCalendar>;
    remove(id: string, req: any): Promise<void>;
}
