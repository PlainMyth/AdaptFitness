import { User } from '../user/user.entity';
export declare class GoalCalendar {
    id: string;
    userId: string;
    user: User;
    weekStartDate: Date;
    weekEndDate: Date;
    goalType: string;
    targetValue: number;
    currentValue: number;
    completionPercentage: number;
    isCompleted: boolean;
    isActive: boolean;
    description: string;
    workoutType: string;
    progressHistory: any[];
    createdAt: Date;
    updatedAt: Date;
    get weekIdentifier(): string;
    private getWeekNumber;
    get status(): string;
    get daysRemaining(): number;
    get isCurrentWeek(): boolean;
    get unit(): string;
}
