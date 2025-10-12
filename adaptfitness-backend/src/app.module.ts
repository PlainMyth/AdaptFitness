/**
 * Main Application Module
 *
 * This is the root module of the AdaptFitness API application.
 * It imports and configures all other modules, sets up the database connection,
 * and configures authentication and other global services.
 *
 * Key responsibilities:
 * - Import and configure all feature modules
 * - Set up database connection (PostgreSQL)
 * - Configure authentication (JWT + Passport)
 * - Set up environment variable management
 * - Export shared services for use across modules
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { WorkoutModule } from './workout/workout.module';
import { MealModule } from './meal/meal.module';
import { HealthMetricsModule } from './health-metrics/health-metrics.module';
import { GoalCalendarModule } from './goal-calendar/goal-calendar.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { JwtStrategy } from './auth/strategies/jwt.strategy';

@Module({
  imports: [
    // Global configuration module for environment variables
    ConfigModule.forRoot({
      isGlobal: true,        // Make environment variables available globally
      envFilePath: '.env',   // Path to environment file
    }),
    
    // Database configuration using TypeORM with PostgreSQL
    TypeOrmModule.forRoot({
      type: 'postgres',      // Database type
      host: process.env.DATABASE_HOST || 'localhost',                    // Database host
      port: parseInt(process.env.DATABASE_PORT) || 5432,                 // Database port
      username: process.env.DATABASE_USERNAME || 'postgres',             // Database username
      password: process.env.DATABASE_PASSWORD || 'password',             // Database password
      database: process.env.DATABASE_NAME || 'adaptfitness',             // Database name
      entities: [__dirname + '/**/*.entity{.ts,.js}'],                   // Auto-load all entity files
      synchronize: process.env.NODE_ENV !== 'production',                // Auto-sync schema in development
      logging: process.env.NODE_ENV === 'development',                   // Enable SQL logging in development
    }),
    
    // Passport authentication module
    PassportModule.register({ 
      defaultStrategy: 'jwt'  // Use JWT as the default authentication strategy
    }),
    
    // JWT token configuration
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production-adaptfitness-2024',
      signOptions: { 
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'  // Token expiration time
      },
    }),
    
    // Feature modules
    AuthModule,              // Authentication and user management
    UserModule,              // User profile and account management
    WorkoutModule,           // Workout tracking and management
    MealModule,              // Meal logging and nutrition tracking
    HealthMetricsModule,     // Health metrics and body composition
    GoalCalendarModule,      // Goal calendar and weekly fitness goals
  ],
  
  // Root-level controllers
  controllers: [AppController],
  
  // Root-level services and strategies
  providers: [AppService, JwtStrategy],
  
  // Export JWT strategy for use in other modules
  exports: [JwtStrategy],
})
export class AppModule {}
