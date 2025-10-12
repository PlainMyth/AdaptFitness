import { MealService } from './meal.service';
export declare class MealController {
    private mealService;
    constructor(mealService: MealService);
    create(req: any, mealData: any): Promise<import("./meal.entity").Meal>;
    findAll(req: any): Promise<import("./meal.entity").Meal[]>;
    getCurrentStreak(req: any, tz?: string): Promise<{
        streak: number;
        lastMealDate?: string;
    }>;
    findOne(req: any, id: string): Promise<import("./meal.entity").Meal>;
    update(req: any, id: string, updateData: any): Promise<import("./meal.entity").Meal>;
    remove(req: any, id: string): Promise<{
        message: string;
    }>;
}
