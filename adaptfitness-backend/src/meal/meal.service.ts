import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Meal } from './meal.entity';

@Injectable()
export class MealService {
  constructor(
    @InjectRepository(Meal)
    private mealRepository: Repository<Meal>,
  ) {}

  async create(mealData: Partial<Meal>): Promise<Meal> {
    const meal = this.mealRepository.create(mealData);
    return this.mealRepository.save(meal);
  }

  async findAll(userId: string): Promise<Meal[]> {
    return this.mealRepository.find({
      where: { userId },
      order: { mealTime: 'DESC' }
    });
  }

  async findOne(id: string, userId: string): Promise<Meal> {
    const meal = await this.mealRepository.findOne({
      where: { id, userId }
    });
    
    if (!meal) {
      throw new NotFoundException('Meal not found');
    }
    
    return meal;
  }

  async update(id: string, userId: string, updateData: Partial<Meal>): Promise<Meal> {
    const meal = await this.findOne(id, userId);
    Object.assign(meal, updateData);
    return this.mealRepository.save(meal);
  }

  async remove(id: string, userId: string): Promise<void> {
    const result = await this.mealRepository.delete({ id, userId });
    if (result.affected === 0) {
      throw new NotFoundException('Meal not found');
    }
  }
}
