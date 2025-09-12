import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Workout } from './workout.entity';

@Injectable()
export class WorkoutService {
  constructor(
    @InjectRepository(Workout)
    private workoutRepository: Repository<Workout>,
  ) {}

  async create(workoutData: Partial<Workout>): Promise<Workout> {
    const workout = this.workoutRepository.create(workoutData);
    return this.workoutRepository.save(workout);
  }

  async findAll(userId: string): Promise<Workout[]> {
    return this.workoutRepository.find({
      where: { userId },
      order: { startTime: 'DESC' }
    });
  }

  async findOne(id: string, userId: string): Promise<Workout> {
    const workout = await this.workoutRepository.findOne({
      where: { id, userId }
    });
    
    if (!workout) {
      throw new NotFoundException('Workout not found');
    }
    
    return workout;
  }

  async update(id: string, userId: string, updateData: Partial<Workout>): Promise<Workout> {
    const workout = await this.findOne(id, userId);
    Object.assign(workout, updateData);
    return this.workoutRepository.save(workout);
  }

  async remove(id: string, userId: string): Promise<void> {
    const result = await this.workoutRepository.delete({ id, userId });
    if (result.affected === 0) {
      throw new NotFoundException('Workout not found');
    }
  }
}
