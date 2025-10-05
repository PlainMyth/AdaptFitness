export declare class CreateWorkoutDto {
    name: string;
    description: string;
    startTime: Date;
    endTime?: Date;
    totalCaloriesBurned?: number;
    totalDuration?: number;
    notes?: string;
    userId: string;
}
