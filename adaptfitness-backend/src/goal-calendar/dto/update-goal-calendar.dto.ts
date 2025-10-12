import { PartialType } from '@nestjs/mapped-types';
import { CreateGoalCalendarDto } from './create-goal-calendar.dto';

export class UpdateGoalCalendarDto extends PartialType(CreateGoalCalendarDto) {}
