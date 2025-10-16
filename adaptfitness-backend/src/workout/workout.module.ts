/**
 * Workout Module
 *
 * This module configures all workout-related components including the controller, service, and entity. It also sets up the database repository for workout operations.
 *
 * Key responsibilities:
 * - Configure workout-related components
 * - Set up database repository
 * - Register workout services
 * - Export shared workout utilities
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Workout } from './workout.entity';
import { WorkoutService } from './workout.service';
import { WorkoutController } from './workout.controller';
import { UserModule } from '../user/user.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Workout]),
    UserModule,
    AuthModule,
  ],
  providers: [WorkoutService],
  controllers: [WorkoutController],
  exports: [WorkoutService],
})
export class WorkoutModule {}
