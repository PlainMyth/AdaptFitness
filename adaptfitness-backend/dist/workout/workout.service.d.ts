import { Repository } from 'typeorm';
import { Workout } from './workout.entity';
export declare class WorkoutService {
    private workoutRepository;
    constructor(workoutRepository: Repository<Workout>);
    create(workoutData: Partial<Workout>): Promise<Workout>;
    findAll(userId: string): Promise<Workout[]>;
    findOne(id: string, userId: string): Promise<Workout>;
    update(id: string, userId: string, updateData: Partial<Workout>): Promise<Workout>;
    remove(id: string, userId: string): Promise<void>;
}
