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
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { WorkoutModule } from './workout/workout.module';
import { MealModule } from './meal/meal.module';
import { HealthMetricsModule } from './health-metrics/health-metrics.module';
import { GoalCalendarModule } from './goal-calendar/goal-calendar.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { JwtStrategy } from './auth/strategies/jwt.strategy';
import { throttlerConfig } from './config/throttler.config';

@Module({
  imports: [
    // Global configuration module for environment variables
    ConfigModule.forRoot({
      isGlobal: true,        // Make environment variables available globally
      envFilePath: '.env',   // Path to environment file
    }),
    
    // Database configuration using TypeORM with PostgreSQL
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres' as const,
        host: configService.get<string>('DATABASE_HOST') || 'localhost',
        port: configService.get<number>('DATABASE_PORT') || 5432,
        username: configService.get<string>('DATABASE_USERNAME') || 'postgres',
        password: configService.get<string>('DATABASE_PASSWORD') || 'password',
        database: configService.get<string>('DATABASE_NAME') || 'adaptfitness',
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        // Allow explicit control of synchronize via env var for initial deployment
        // Set TYPEORM_SYNCHRONIZE=true for initial table creation, then false for production
        synchronize: configService.get<string>('TYPEORM_SYNCHRONIZE') === 'true' 
          ? true 
          : process.env.NODE_ENV !== 'production',
        logging: process.env.NODE_ENV === 'development',
      }),
      inject: [ConfigService],
    }),
    
    // Passport authentication module
    PassportModule.register({ 
      defaultStrategy: 'jwt'  // Use JWT as the default authentication strategy
    }),
    
    // JWT token configuration - using registerAsync for proper config loading
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: { 
          expiresIn: configService.get<string>('JWT_EXPIRES_IN') || '24h'
        },
      }),
      inject: [ConfigService],
    }),
    
    // Rate limiting module - prevents brute force attacks
    ThrottlerModule.forRoot(throttlerConfig),
    
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
  providers: [
    AppService, 
    JwtStrategy,
    // Apply rate limiting globally to all endpoints
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
  
  // Export JWT strategy for use in other modules
  exports: [JwtStrategy],
})
export class AppModule {}
