import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GoalCalendarService } from './goal-calendar.service';
import { GoalCalendarController } from './goal-calendar.controller';
import { GoalCalendar } from './goal-calendar.entity';
import { User } from '../user/user.entity';
import { WorkoutModule } from '../workout/workout.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([GoalCalendar, User]),
    WorkoutModule, // Import WorkoutModule to access WorkoutService
  ],
  controllers: [GoalCalendarController],
  providers: [GoalCalendarService],
  exports: [GoalCalendarService],
})
export class GoalCalendarModule {}
