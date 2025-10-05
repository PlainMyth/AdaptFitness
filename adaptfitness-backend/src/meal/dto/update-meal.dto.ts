/**
 * Update Meal DTO
 *
 * This DTO defines the data structure for updating existing meal entries.
 * All fields are optional to allow partial updates.
 *
 * Key responsibilities:
 * - Define meal update data structure
 * - Allow partial updates of meal data
 * - Provide type safety for meal updates
 */
export class UpdateMealDto {
  name?: string;
  description?: string;
  mealTime?: Date;
  totalCalories?: number;
  notes?: string;
  userId?: string;
}