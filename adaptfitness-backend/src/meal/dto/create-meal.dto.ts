/**
 * Create Meal DTO
 *
 * This DTO defines the data structure for creating new meal entries.
 * Validation is handled in the service layer for better control and error handling.
 *
 * Key responsibilities:
 * - Define meal creation data structure
 * - Provide type safety for meal creation
 * - Serve as a contract for API consumers
 */
export class CreateMealDto {
  name: string;
  description: string;
  mealTime: Date;
  totalCalories?: number;
  notes?: string;
  userId: string;
}