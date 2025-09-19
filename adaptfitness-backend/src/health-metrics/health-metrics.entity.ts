/**
 * Health Metrics Entity
 * 
 * This defines the database table structure for storing health metrics.
 * It represents all the health and body composition data for a user.
 * 
 * Key features:
 * - Links to a specific user (many-to-one relationship)
 * - Stores both raw measurements and calculated metrics
 * - Includes comprehensive body composition data
 * - Automatically tracks creation and update times
 * 
 * Database table: 'health_metrics'
 */

import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../user/user.entity';

// @Entity decorator tells TypeORM this class represents a database table
@Entity('health_metrics')
export class HealthMetrics {
  // Primary key - automatically generated unique ID
  @PrimaryGeneratedColumn()
  id: number;

  // Foreign key - links this health metrics entry to a specific user
  @Column({ type: 'uuid' })
  userId: string;

  // Relationship to User entity - when user is deleted, their health metrics are too
  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  // Body Composition Metrics
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  bodyFatPercentage: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  leanBodyMass: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  skeletalMuscleMass: number;

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  currentWeight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  goalWeight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  waterPercentage: number;

  // Advanced Body Calculations
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  absi: number; // A Body Shape Index

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  maximumFatLoss: number; // Safe weekly fat loss limit

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  calorieDeficit: number;

  // Metabolic Calculations
  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  tdee: number; // Total Daily Energy Expenditure

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  rmr: number; // Resting Metabolic Rate

  @Column({ type: 'decimal', precision: 3, scale: 2, nullable: true })
  physicalActivityLevel: number;

  // Additional Measurements
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  waistCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  hipCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  chestCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  thighCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  armCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  neckCircumference: number;

  // Calculated Ratios
  @Column({ type: 'decimal', precision: 4, scale: 3, nullable: true })
  waistToHipRatio: number;

  @Column({ type: 'decimal', precision: 4, scale: 3, nullable: true })
  waistToHeightRatio: number;

  @Column({ type: 'decimal', precision: 4, scale: 2, nullable: true })
  bmi: number;

  // Metadata
  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
