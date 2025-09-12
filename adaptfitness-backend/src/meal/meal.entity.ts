import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../user/user.entity';

@Entity('meals')
export class Meal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  description: string;

  @Column({ type: 'timestamp' })
  mealTime: Date;

  @Column({ default: 0 })
  totalCalories: number;

  @Column({ default: 0 })
  totalProtein: number; // in grams

  @Column({ default: 0 })
  totalCarbs: number; // in grams

  @Column({ default: 0 })
  totalFat: number; // in grams

  @Column({ default: 0 })
  totalFiber: number; // in grams

  @Column({ default: 0 })
  totalSugar: number; // in grams

  @Column({ default: 0 })
  totalSodium: number; // in mg

  @Column({ 
    nullable: true,
    type: 'enum',
    enum: ['breakfast', 'lunch', 'dinner', 'snack', 'other']
  })
  mealType: string;

  @Column({ default: 0 })
  servingSize: number; // in grams or pieces

  @Column({ nullable: true })
  servingUnit: string; // grams, pieces, cups, etc.

  @ManyToOne(() => User, user => user.meals)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Helper method to calculate macronutrient percentages
  get proteinPercentage(): number {
    if (this.totalCalories === 0) return 0;
    return Number(((this.totalProtein * 4) / this.totalCalories * 100).toFixed(1));
  }

  get carbsPercentage(): number {
    if (this.totalCalories === 0) return 0;
    return Number(((this.totalCarbs * 4) / this.totalCalories * 100).toFixed(1));
  }

  get fatPercentage(): number {
    if (this.totalCalories === 0) return 0;
    return Number(((this.totalFat * 9) / this.totalCalories * 100).toFixed(1));
  }
}
