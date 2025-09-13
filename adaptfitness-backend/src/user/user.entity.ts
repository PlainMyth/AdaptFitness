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
    enum: ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active']
  })
  activityLevel: string;

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

  // Helper method to calculate BMI
  get bmi(): number | null {
    if (!this.height || !this.weight) return null;
    const heightInMeters = this.height / 100;
    return Number((this.weight / (heightInMeters * heightInMeters)).toFixed(1));
  }
}
