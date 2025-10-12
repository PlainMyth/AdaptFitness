import { Repository } from 'typeorm';
import { Meal } from './meal.entity';
export declare class MealService {
    private mealRepository;
    constructor(mealRepository: Repository<Meal>);
    create(mealData: Partial<Meal>): Promise<Meal>;
    findAll(userId: string): Promise<Meal[]>;
    findOne(id: string, userId: string): Promise<Meal>;
    update(id: string, userId: string, updateData: Partial<Meal>): Promise<Meal>;
    remove(id: string, userId: string): Promise<void>;
    getCurrentStreak(userId: string): Promise<{
        streak: number;
        lastMealDate?: string;
    }>;
    getCurrentStreakInTimeZone(userId: string, timeZone?: string): Promise<{
        streak: number;
        lastMealDate?: string;
    }>;
    private validateTimeZone;
    private getDateKeyInTimeZone;
    private getKeyForDaysAgo;
}
