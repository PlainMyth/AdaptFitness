/**
 * Meal Module
 *
 * This module configures all meal-related components including the controller, service, and entity. It also sets up the database repository for meal operations.
 *
 * Key responsibilities:
- Configure meal-related components\n * - Set up database repository\n * - Register meal services\n * - Export shared meal utilities
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Meal } from './meal.entity';
import { MealService } from './meal.service';
import { MealController } from './meal.controller';
import { UserModule } from '../user/user.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Meal]),
    UserModule,
    AuthModule,
  ],
  providers: [MealService],
  controllers: [MealController],
  exports: [MealService],
})
export class MealModule {}
