import { User } from '../user/user.entity';
export declare class Meal {
    id: string;
    name: string;
    description: string;
    mealTime: Date;
    totalCalories: number;
    totalProtein: number;
    totalCarbs: number;
    totalFat: number;
    totalFiber: number;
    totalSugar: number;
    totalSodium: number;
    mealType: string;
    servingSize: number;
    servingUnit: string;
    user: User;
    userId: string;
    createdAt: Date;
    updatedAt: Date;
    get proteinPercentage(): number;
    get carbsPercentage(): number;
    get fatPercentage(): number;
}
