import { CreateHealthMetricsDto } from './create-health-metrics.dto';

export class UpdateHealthMetricsDto {
  currentWeight?: number;
  bodyFatPercentage?: number;
  goalWeight?: number;
  waterPercentage?: number;
  waistCircumference?: number;
  hipCircumference?: number;
  chestCircumference?: number;
  thighCircumference?: number;
  armCircumference?: number;
  neckCircumference?: number;
  notes?: string;
}
