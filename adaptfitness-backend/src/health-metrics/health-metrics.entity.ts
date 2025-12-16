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
import { Transform } from 'class-transformer';

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
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  bodyFatPercentage: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  leanBodyMass: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  skeletalMuscleMass: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, transformer: { to: v => v, from: v => parseFloat(v) } })
  currentWeight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  goalWeight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  waterPercentage: number;

  // Advanced Body Calculations
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  absi: number; // A Body Shape Index

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  maximumFatLoss: number; // Safe weekly fat loss limit

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  calorieDeficit: number;

  // Metabolic Calculations
  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  tdee: number; // Total Daily Energy Expenditure

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  rmr: number; // Resting Metabolic Rate

  @Column({ type: 'decimal', precision: 3, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  physicalActivityLevel: number;

  // Additional Measurements
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  waistCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  hipCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  chestCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  thighCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  armCircumference: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  neckCircumference: number;

  // Calculated Ratios
  @Column({ type: 'decimal', precision: 4, scale: 3, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  waistToHipRatio: number;

  @Column({ type: 'decimal', precision: 4, scale: 3, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  waistToHeightRatio: number;

  @Column({ type: 'decimal', precision: 4, scale: 2, nullable: true, transformer: { to: v => v, from: v => v ? parseFloat(v) : null } })
  bmi: number;

  // Metadata
  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
