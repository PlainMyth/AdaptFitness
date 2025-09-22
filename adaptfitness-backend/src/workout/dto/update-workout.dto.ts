/**
 * Update Workout DTO
 *
 * This DTO defines the data structure for updating existing workout entries.
 * All fields are optional to allow partial updates.
 *
 * Key responsibilities:
 * - Define workout update data structure
 * - Allow partial updates of workout data
 * - Provide type safety for workout updates
 */
export class UpdateWorkoutDto {
  name?: string;
  description?: string;
  startTime?: Date;
  endTime?: Date;
  totalCaloriesBurned?: number;
  totalDuration?: number; // in minutes
  notes?: string;
  userId?: string;
}