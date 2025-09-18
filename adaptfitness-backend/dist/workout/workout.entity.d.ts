import { User } from '../user/user.entity';
export declare class Workout {
    id: string;
    name: string;
    description: string;
    startTime: Date;
    endTime: Date;
    totalCaloriesBurned: number;
    totalDuration: number;
    totalSets: number;
    totalReps: number;
    totalWeight: number;
    workoutType: string;
    isCompleted: boolean;
    user: User;
    userId: string;
    createdAt: Date;
    updatedAt: Date;
    get duration(): number;
    get status(): string;
}
