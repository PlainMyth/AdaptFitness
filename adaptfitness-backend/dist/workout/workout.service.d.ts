import { Repository } from 'typeorm';
import { Workout } from './workout.entity';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
export declare class WorkoutService {
    private workoutRepository;
    constructor(workoutRepository: Repository<Workout>);
    private validateCreateWorkoutDto;
    private validateUpdateWorkoutDto;
    create(createWorkoutDto: CreateWorkoutDto): Promise<Workout>;
    findAll(userId: string): Promise<Workout[]>;
    findOne(id: string): Promise<Workout>;
    update(id: string, updateWorkoutDto: UpdateWorkoutDto): Promise<Workout>;
    remove(id: string): Promise<void>;
    getCurrentStreakInTimeZone(userId: string, timeZone?: string): Promise<{
        streak: number;
        lastWorkoutDate: string | null;
    }>;
    private getDateKeyInTimeZone;
    private getKeyForDaysAgo;
}
