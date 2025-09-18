/**
 * Health Metrics Service
 * 
 * This service contains all the business logic for health metrics.
 * It's the "brain" of the health metrics feature, handling:
 * - CRUD operations (Create, Read, Update, Delete)
 * - Complex health calculations (BMI, TDEE, RMR, etc.)
 * - Data validation and processing
 * - Integration with the database
 * 
 * Key responsibilities:
 * - Calculate health metrics from raw data
 * - Store and retrieve health data
 * - Validate user permissions
 * - Handle business rules and calculations
 */

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HealthMetrics } from './health-metrics.entity';
import { User } from '../user/user.entity';
import { CreateHealthMetricsDto } from './dto/create-health-metrics.dto';
import { UpdateHealthMetricsDto } from './dto/update-health-metrics.dto';

// @Injectable decorator tells NestJS this class can be injected into other classes
@Injectable()
export class HealthMetricsService {
  constructor(
    // Inject the HealthMetrics repository - this gives us access to the database
    @InjectRepository(HealthMetrics)
    private healthMetricsRepository: Repository<HealthMetrics>,
    // Inject the User repository - we need this for user data in calculations
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  /**
   * CREATE - Creates a new health metrics entry
   * 
   * What this does:
   * 1. Takes raw health data from the user (weight, measurements, etc.)
   * 2. Creates a new database record
   * 3. Calculates all derived metrics (BMI, TDEE, RMR, etc.)
   * 4. Saves everything to the database
   * 
   * @param createHealthMetricsDto - The health data from the user
   * @param userId - The ID of the user creating the entry
   * @returns The complete health metrics record with calculations
   */
  async create(createHealthMetricsDto: CreateHealthMetricsDto, userId: string): Promise<HealthMetrics> {
    // Create a new health metrics object with the user's data
    const healthMetrics = this.healthMetricsRepository.create({
      ...createHealthMetricsDto, // Spread the user's input data
      userId, // Add the user ID to link this data to the user
    });

    // Calculate all derived metrics (BMI, TDEE, RMR, etc.)
    const calculatedMetrics = await this.calculateAllMetrics(healthMetrics, userId);
    
    // Save the complete record to the database
    return this.healthMetricsRepository.save(calculatedMetrics);
  }

  /**
   * READ ALL - Gets all health metrics for a user
   * 
   * What this does:
   * 1. Finds all health metrics entries for the specified user
   * 2. Orders them by creation date (newest first)
   * 3. Returns the complete list
   * 
   * @param userId - The ID of the user to get metrics for
   * @returns Array of all health metrics for the user
   */
  async findAll(userId: string): Promise<HealthMetrics[]> {
    return this.healthMetricsRepository.find({
      where: { userId }, // Only get metrics for this specific user
      order: { createdAt: 'DESC' }, // Newest entries first
    });
  }

  /**
   * READ ONE - Gets a specific health metrics entry
   * 
   * What this does:
   * 1. Looks for a specific health metrics entry by ID
   * 2. Ensures it belongs to the specified user (security)
   * 3. Returns the entry or throws an error if not found
   * 
   * @param id - The ID of the health metrics entry to find
   * @param userId - The ID of the user (for security)
   * @returns The specific health metrics entry
   * @throws NotFoundException if the entry doesn't exist or doesn't belong to the user
   */
  async findOne(id: number, userId: string): Promise<HealthMetrics> {
    const healthMetrics = await this.healthMetricsRepository.findOne({
      where: { id, userId }, // Find by ID AND user ID (security check)
    });

    if (!healthMetrics) {
      throw new NotFoundException('Health metrics not found');
    }

    return healthMetrics;
  }

  /**
   * READ LATEST - Gets the most recent health metrics entry
   * 
   * What this does:
   * 1. Finds the newest health metrics entry for the user
   * 2. Useful for showing current health status
   * 3. Returns the latest entry or throws an error if none exist
   * 
   * @param userId - The ID of the user to get the latest metrics for
   * @returns The most recent health metrics entry
   * @throws NotFoundException if no health metrics exist for the user
   */
  async findLatest(userId: string): Promise<HealthMetrics> {
    const healthMetrics = await this.healthMetricsRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' }, // Get the newest one
    });

    if (!healthMetrics) {
      throw new NotFoundException('No health metrics found');
    }

    return healthMetrics;
  }

  /**
   * UPDATE - Updates an existing health metrics entry
   * 
   * What this does:
   * 1. Finds the existing health metrics entry
   * 2. Merges the new data with the existing data
   * 3. Recalculates all derived metrics with the new data
   * 4. Saves the updated entry
   * 
   * @param id - The ID of the health metrics entry to update
   * @param updateHealthMetricsDto - The new data to update with
   * @param userId - The ID of the user (for security)
   * @returns The updated health metrics entry
   */
  async update(id: number, updateHealthMetricsDto: UpdateHealthMetricsDto, userId: string): Promise<HealthMetrics> {
    // First, get the existing entry (this also validates ownership)
    const healthMetrics = await this.findOne(id, userId);
    
    // Merge the existing data with the new data
    Object.assign(healthMetrics, updateHealthMetricsDto);
    
    // Recalculate all derived metrics with the updated data
    const calculatedMetrics = await this.calculateAllMetrics(healthMetrics, userId);
    
    // Save the updated record
    return this.healthMetricsRepository.save(calculatedMetrics);
  }

  /**
   * DELETE - Removes a health metrics entry
   * 
   * What this does:
   * 1. Finds the health metrics entry (validates ownership)
   * 2. Permanently deletes it from the database
   * 
   * @param id - The ID of the health metrics entry to delete
   * @param userId - The ID of the user (for security)
   */
  async remove(id: number, userId: string): Promise<void> {
    // First, get the existing entry (this also validates ownership)
    const healthMetrics = await this.findOne(id, userId);
    // Delete the entry from the database
    await this.healthMetricsRepository.remove(healthMetrics);
  }

  // Advanced Calculation Methods
  private async calculateAllMetrics(healthMetrics: HealthMetrics, userId: string): Promise<HealthMetrics> {
    // Get user data for calculations
    const user = await this.getUserData(userId);
    
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Calculate BMI
    healthMetrics.bmi = this.calculateBMI(healthMetrics.currentWeight, user.height);

    // Calculate body composition
    if (healthMetrics.bodyFatPercentage) {
      healthMetrics.leanBodyMass = this.calculateLeanBodyMass(
        healthMetrics.currentWeight,
        healthMetrics.bodyFatPercentage
      );
      healthMetrics.skeletalMuscleMass = this.calculateSkeletalMuscleMass(
        healthMetrics.currentWeight,
        user.height,
        user.gender
      );
    }

    // Calculate ratios
    if (healthMetrics.waistCircumference && healthMetrics.hipCircumference) {
      healthMetrics.waistToHipRatio = this.calculateWaistToHipRatio(
        healthMetrics.waistCircumference,
        healthMetrics.hipCircumference
      );
    }

    if (healthMetrics.waistCircumference && user.height) {
      healthMetrics.waistToHeightRatio = this.calculateWaistToHeightRatio(
        healthMetrics.waistCircumference,
        user.height
      );
    }

    // Calculate ABSI
    if (healthMetrics.waistCircumference) {
      healthMetrics.absi = this.calculateABSI(
        healthMetrics.currentWeight,
        user.height,
        healthMetrics.waistCircumference
      );
    }

    // Calculate metabolic metrics
    healthMetrics.rmr = this.calculateRMR(
      healthMetrics.currentWeight,
      user.height,
      user.age,
      user.gender
    );

    healthMetrics.physicalActivityLevel = user.activityLevel || 1.4;
    healthMetrics.tdee = this.calculateTDEE(healthMetrics.rmr, healthMetrics.physicalActivityLevel);

    // Calculate fat loss metrics
    if (healthMetrics.bodyFatPercentage) {
      healthMetrics.maximumFatLoss = this.calculateMaximumFatLoss(
        healthMetrics.currentWeight,
        healthMetrics.bodyFatPercentage
      );
    }

    // Calculate calorie deficit (if goal weight is set)
    if (healthMetrics.goalWeight) {
      healthMetrics.calorieDeficit = this.calculateCalorieDeficit(
        healthMetrics.tdee,
        healthMetrics.currentWeight,
        healthMetrics.goalWeight
      );
    }

    return healthMetrics;
  }

  // Body Composition Calculations
  private calculateBMI(weight: number, height: number): number {
    const heightInMeters = height / 100;
    return Number((weight / (heightInMeters * heightInMeters)).toFixed(2));
  }

  private calculateLeanBodyMass(weight: number, bodyFatPercentage: number): number {
    return Number((weight * (1 - bodyFatPercentage / 100)).toFixed(2));
  }

  private calculateSkeletalMuscleMass(weight: number, height: number, gender: string): number {
    // Boer formula for skeletal muscle mass
    if (gender === 'male') {
      return Number((0.407 * weight + 0.267 * height - 19.2).toFixed(2));
    } else {
      return Number((0.252 * weight + 0.473 * height - 48.3).toFixed(2));
    }
  }

  private calculateWaistToHipRatio(waist: number, hip: number): number {
    return Number((waist / hip).toFixed(3));
  }

  private calculateWaistToHeightRatio(waist: number, height: number): number {
    return Number((waist / height).toFixed(3));
  }

  private calculateABSI(weight: number, height: number, waist: number): number {
    const heightInMeters = height / 100;
    const weightInKg = weight;
    const waistInMeters = waist / 100;
    
    return Number((waistInMeters / (Math.pow(weightInKg, 2/3) * Math.pow(heightInMeters, 1/2))).toFixed(3));
  }

  // Metabolic Calculations
  private calculateRMR(weight: number, height: number, age: number, gender: string): number {
    // Mifflin-St Jeor Equation
    if (gender === 'male') {
      return Number((10 * weight + 6.25 * height - 5 * age + 5).toFixed(2));
    } else {
      return Number((10 * weight + 6.25 * height - 5 * age - 161).toFixed(2));
    }
  }

  private calculateTDEE(rmr: number, activityLevel: number): number {
    return Number((rmr * activityLevel).toFixed(2));
  }

  private calculateMaximumFatLoss(weight: number, bodyFatPercentage: number): number {
    // Safe maximum fat loss is 1% of body weight per week
    const maxLossPerWeek = weight * 0.01;
    return Number(maxLossPerWeek.toFixed(2));
  }

  private calculateCalorieDeficit(tdee: number, currentWeight: number, goalWeight: number): number {
    const weightDifference = currentWeight - goalWeight;
    if (weightDifference <= 0) return 0;
    
    // Assuming 1 lb = 3500 calories, calculate daily deficit needed
    const weeklyDeficit = weightDifference * 3500;
    const dailyDeficit = weeklyDeficit / 7;
    
    return Number(dailyDeficit.toFixed(2));
  }

  // Helper method to get user data
  private async getUserData(userId: string): Promise<{ height: number; age: number; gender: string; activityLevel?: number } | null> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) return null;

    return {
      height: user.height || 175, // cm
      age: user.age || 25,
      gender: user.gender || 'male',
      activityLevel: user.activityLevelMultiplier || 1.4
    };
  }

  // Get calculated metrics for a user
  async getCalculatedMetrics(userId: string): Promise<{
    bmi: number;
    tdee: number;
    rmr: number;
    bodyFatCategory: string;
    bmiCategory: string;
  }> {
    const latest = await this.findLatest(userId);
    
    return {
      bmi: latest.bmi,
      tdee: latest.tdee,
      rmr: latest.rmr,
      bodyFatCategory: this.getBodyFatCategory(latest.bodyFatPercentage, latest.user?.gender || 'male'),
      bmiCategory: this.getBMICategory(latest.bmi),
    };
  }

  private getBodyFatCategory(bodyFatPercentage: number, gender: string): string {
    if (!bodyFatPercentage) return 'Unknown';
    
    if (gender === 'male') {
      if (bodyFatPercentage < 6) return 'Essential Fat';
      if (bodyFatPercentage < 14) return 'Athletes';
      if (bodyFatPercentage < 18) return 'Fitness';
      if (bodyFatPercentage < 25) return 'Average';
      return 'Obese';
    } else {
      if (bodyFatPercentage < 10) return 'Essential Fat';
      if (bodyFatPercentage < 16) return 'Athletes';
      if (bodyFatPercentage < 20) return 'Fitness';
      if (bodyFatPercentage < 32) return 'Average';
      return 'Obese';
    }
  }

  private getBMICategory(bmi: number): string {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
