import 'reflect-metadata';
import { IsNumber, IsOptional, IsString, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateHealthMetricsDto {
  @IsNumber()
  @Type(() => Number)
  currentWeight: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(100)
  bodyFatPercentage?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  goalWeight?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(100)
  waterPercentage?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  waistCircumference?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  hipCircumference?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  chestCircumference?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  thighCircumference?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  armCircumference?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  neckCircumference?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
