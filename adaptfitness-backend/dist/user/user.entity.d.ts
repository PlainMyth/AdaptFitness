import { Workout } from '../workout/workout.entity';
import { Meal } from '../meal/meal.entity';
export declare class User {
    id: string;
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    dateOfBirth: Date;
    height: number;
    weight: number;
    gender: string;
    activityLevel: string;
    activityLevelMultiplier: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    workouts: Workout[];
    meals: Meal[];
    get fullName(): string;
    get age(): number | null;
    get bmi(): number | null;
}
