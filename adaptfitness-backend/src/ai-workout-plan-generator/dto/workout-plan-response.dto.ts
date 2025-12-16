import { EnrichmentStats } from '../interfaces/workout-plan.interface';

export class WorkoutPlanResponseDto {
  success: boolean;
  data?: any;
  enrichmentStats?: EnrichmentStats;
  message: string;
  error?: string;
}
