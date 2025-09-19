/**
 * User Entity
 *
 * This defines the database table structure for storing user information.
 * It represents all the user data including profile information, health metrics,
 * and relationships to other entities like workouts and meals.
 *
 * Key responsibilities:
 * - Store user authentication and profile data
 * - Include health-related fields for calculations
 * - Define relationships to other entities
 * - Provide helper methods for common operations
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Workout } from '../workout/workout.entity';
import { Meal } from '../meal/meal.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({ nullable: true })
  dateOfBirth: Date;

  @Column({ nullable: true })
  height: number; // in cm

  @Column({ nullable: true })
  weight: number; // in kg

  @Column({
    nullable: true,
    type: 'enum',
    enum: ['male', 'female', 'other']
  })
  gender: string;

  @Column({ 
    nullable: true,
    type: 'enum',
    enum: ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active']
  })
  activityLevel: string;

  @Column({ type: 'decimal', precision: 3, scale: 2, nullable: true })
  activityLevelMultiplier: number; // 1.2, 1.375, 1.55, 1.725, 1.9

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Workout, workout => workout.user)
  workouts: Workout[];

  @OneToMany(() => Meal, meal => meal.user)
  meals: Meal[];

  // Helper method to get full name
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }

  // Helper method to calculate age from date of birth
  get age(): number | null {
    if (!this.dateOfBirth) return null;
    const today = new Date();
    const birthDate = new Date(this.dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  }

  // Helper method to calculate BMI
  get bmi(): number | null {
    if (!this.height || !this.weight) return null;
    const heightInMeters = this.height / 100;
    return Number((this.weight / (heightInMeters * heightInMeters)).toFixed(1));
  }
}
