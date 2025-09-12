import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../user/user.entity';

@Entity('workouts')
export class Workout {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  description: string;

  @Column({ type: 'timestamp' })
  startTime: Date;

  @Column({ type: 'timestamp', nullable: true })
  endTime: Date;

  @Column({ default: 0 })
  totalCaloriesBurned: number;

  @Column({ default: 0 })
  totalDuration: number; // in minutes

  @Column({ default: 0 })
  totalSets: number;

  @Column({ default: 0 })
  totalReps: number;

  @Column({ default: 0 })
  totalWeight: number; // in kg

  @Column({ 
    nullable: true,
    type: 'enum',
    enum: ['strength', 'cardio', 'flexibility', 'sports', 'other']
  })
  workoutType: string;

  @Column({ default: false })
  isCompleted: boolean;

  @ManyToOne(() => User, user => user.workouts)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Helper method to calculate duration
  get duration(): number {
    if (!this.startTime || !this.endTime) return 0;
    return Math.round((this.endTime.getTime() - this.startTime.getTime()) / (1000 * 60));
  }

  // Helper method to get workout status
  get status(): string {
    if (this.isCompleted) return 'completed';
    if (this.startTime && !this.endTime) return 'in_progress';
    return 'scheduled';
  }
}
