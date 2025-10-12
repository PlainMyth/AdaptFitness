import { WorkoutService } from './workout.service';
export declare class WorkoutController {
    private workoutService;
    constructor(workoutService: WorkoutService);
    create(req: any, workoutData: any): Promise<import("./workout.entity").Workout>;
    findAll(req: any): Promise<import("./workout.entity").Workout[]>;
    getCurrentStreak(req: any, tz?: string): Promise<{
        streak: number;
        lastWorkoutDate?: string;
    }>;
    findOne(req: any, id: string): Promise<import("./workout.entity").Workout>;
    update(req: any, id: string, updateData: any): Promise<import("./workout.entity").Workout>;
    remove(req: any, id: string): Promise<{
        message: string;
    }>;
}
