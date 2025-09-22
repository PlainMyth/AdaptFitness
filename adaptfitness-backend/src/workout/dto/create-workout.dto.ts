/**
 * Create Workout DTO
 *
 * This DTO defines the data structure for creating new workout entries.
 * Validation is handled in the service layer for better control and error handling.
 *
 * Key responsibilities:
 * - Define workout creation data structure
 * - Provide type safety for workout creation
 * - Serve as a contract for API consumers
 */
export class CreateWorkoutDto {
  name: string;
  description: string;
  startTime: Date;
  endTime?: Date;
  totalCaloriesBurned?: number;
  totalDuration?: number; // in minutes
  notes?: string;
  userId: string;
}