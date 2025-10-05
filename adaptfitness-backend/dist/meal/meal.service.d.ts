import { Repository } from 'typeorm';
import { Meal } from './meal.entity';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
export declare class MealService {
    private mealRepository;
    constructor(mealRepository: Repository<Meal>);
    create(createMealDto: CreateMealDto): Promise<Meal>;
    findAll(userId: string): Promise<Meal[]>;
    findOne(id: string): Promise<Meal>;
    update(id: string, updateMealDto: UpdateMealDto): Promise<Meal>;
    remove(id: string): Promise<void>;
    getCurrentStreakInTimeZone(userId: string, timeZone?: string): Promise<{
        streak: number;
        lastMealDate: string | null;
    }>;
    private validateCreateMealDto;
    private validateUpdateMealDto;
    private getDateKeyInTimeZone;
    private getKeyForDaysAgo;
}
