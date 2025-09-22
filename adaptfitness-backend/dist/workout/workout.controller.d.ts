import { WorkoutService } from './workout.service';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
export declare class WorkoutController {
    private readonly workoutService;
    constructor(workoutService: WorkoutService);
    create(req: any, createWorkoutDto: CreateWorkoutDto): Promise<import("./workout.entity").Workout>;
    findAll(req: any): Promise<import("./workout.entity").Workout[]>;
    getCurrentStreak(req: any, timeZone?: string): Promise<{
        streak: number;
        lastWorkoutDate: string | null;
    }>;
    findOne(req: any, id: string): Promise<import("./workout.entity").Workout>;
    update(req: any, id: string, updateData: UpdateWorkoutDto): Promise<import("./workout.entity").Workout>;
    remove(req: any, id: string): Promise<{
        message: string;
    }>;
}
