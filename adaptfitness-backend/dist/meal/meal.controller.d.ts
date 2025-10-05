import { MealService } from './meal.service';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
export declare class MealController {
    private readonly mealService;
    constructor(mealService: MealService);
    create(req: any, createMealDto: CreateMealDto): Promise<import("./meal.entity").Meal>;
    findAll(req: any): Promise<import("./meal.entity").Meal[]>;
    getCurrentStreak(req: any, timeZone?: string): Promise<{
        streak: number;
        lastMealDate: string | null;
    }>;
    findOne(req: any, id: string): Promise<import("./meal.entity").Meal>;
    update(req: any, id: string, updateData: UpdateMealDto): Promise<import("./meal.entity").Meal>;
    remove(req: any, id: string): Promise<{
        message: string;
    }>;
}
