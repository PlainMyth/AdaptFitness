export class WorkoutPlanResponseDto {
  id: string;
  userId: string;
  name: string;
  description: string;
  workoutPlanData: any;
  isActive: boolean;
  isCompleted: boolean;
  completedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export class ActivePlanResponseDto {
  data: WorkoutPlanResponseDto | null;
}

export class GenerateAndSaveResponseDto {
  success: boolean;
  data: WorkoutPlanResponseDto;
  message: string;
}
