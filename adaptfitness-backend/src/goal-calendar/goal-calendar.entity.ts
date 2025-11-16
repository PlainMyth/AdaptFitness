/**
 * Goal Calendar Entity
 *
 * This defines the database table structure for storing user fitness goals and their progress tracking.
 * It represents weekly fitness goals that users can set and track against their workout data.
 *
 * Key responsibilities:
 * - Store weekly fitness goals with specific metrics
 * - Track goal completion status and progress
 * - Link goals to specific weeks and users
 * - Support different goal types (workouts, duration, calories, etc.)
 * - Calculate progress based on actual workout data
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../user/user.entity';

@Entity('goal_calendars')
export class GoalCalendar {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'date' })
  weekStartDate: Date; // Monday of the week this goal applies to

  @Column({ type: 'date' })
  weekEndDate: Date; // Sunday of the week this goal applies to

  @Column({
    type: 'enum',
    enum: ['workouts_count', 'total_duration', 'total_calories', 'total_sets', 'total_reps', 'total_weight', 'streak_days']
  })
  goalType: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  targetValue: number; // The goal target (e.g., 5 workouts, 300 minutes, 1500 calories)

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  currentValue: number; // Current progress towards the goal

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  completionPercentage: number; // Calculated percentage (currentValue / targetValue * 100)

  @Column({ default: false })
  isCompleted: boolean;

  @Column({ default: false })
  isActive: boolean; // Whether this goal is currently active for the week

  @Column({ type: 'text', nullable: true })
  description: string; // User-defined description of the goal

  @Column({ 
    nullable: true,
    type: 'enum',
    enum: ['strength', 'cardio', 'flexibility', 'sports', 'other']
  })
  workoutType: string; // If goal is specific to a workout type

  @Column({ type: 'json', nullable: true })
  progressHistory: any[]; // Array to store daily progress snapshots

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Helper method to get week identifier
  get weekIdentifier(): string {
    const year = this.weekStartDate.getFullYear();
    const weekNumber = this.getWeekNumber(this.weekStartDate);
    return `${year}-W${weekNumber.toString().padStart(2, '0')}`;
  }

  // Helper method to calculate week number
  private getWeekNumber(date: Date): number {
    const start = new Date(date.getFullYear(), 0, 1);
    const diff = date.getTime() - start.getTime();
    const oneWeek = 1000 * 60 * 60 * 24 * 7;
    return Math.floor(diff / oneWeek) + 1;
  }

  // Helper method to get progress status
  get status(): string {
    if (this.isCompleted) return 'completed';
    if (this.completionPercentage >= 100) return 'achieved';
    if (this.completionPercentage >= 75) return 'on_track';
    if (this.completionPercentage >= 50) return 'moderate_progress';
    if (this.completionPercentage > 0) return 'started';
    return 'not_started';
  }

  // Helper method to get days remaining in week
  get daysRemaining(): number {
    const today = new Date();
    const endDate = new Date(this.weekEndDate);
    endDate.setHours(23, 59, 59, 999); // End of day
    
    if (today > endDate) return 0;
    
    const diffTime = endDate.getTime() - today.getTime();
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  // Helper method to check if goal is for current week
  get isCurrentWeek(): boolean {
    const today = new Date();
    const start = new Date(this.weekStartDate);
    const end = new Date(this.weekEndDate);
    
    return today >= start && today <= end;
  }

  // Helper method to get goal unit based on type
  get unit(): string {
    switch (this.goalType) {
      case 'workouts_count': return 'workouts';
      case 'total_duration': return 'minutes';
      case 'total_calories': return 'calories';
      case 'total_sets': return 'sets';
      case 'total_reps': return 'reps';
      case 'total_weight': return 'kg';
      case 'streak_days': return 'days';
      default: return 'units';
    }
  }
}
