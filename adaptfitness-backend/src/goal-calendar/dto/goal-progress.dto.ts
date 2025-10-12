import { IsDateString, IsOptional, IsNumber, IsString } from 'class-validator';

export class GoalProgressDto {
  @IsDateString()
  date: string;

  @IsOptional()
  @IsNumber()
  value?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
