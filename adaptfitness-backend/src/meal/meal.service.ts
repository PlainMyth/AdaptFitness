/**
 * Meal Service
 *
 * This service handles all meal-related business logic including CRUD operations, nutritional calculations, and data validation.
 *
 * Key responsibilities:
- Handle meal business logic\n * - Perform nutritional calculations\n * - Manage meal data persistence\n * - Provide nutrition-related utilities
 */

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

  /**
   * Compute the user's current daily meal streak based on calendar days.
   * A day counts if the user has at least one meal with a mealTime on that day (in UTC).
   * The streak increments for each consecutive prior day with a meal; it resets when a gap is found.
   */
  async getCurrentStreak(userId: string): Promise<{ streak: number; lastMealDate?: string }> {
    return this.getCurrentStreakInTimeZone(userId);
  }

  /**
   * Same as getCurrentStreak but allows specifying user's IANA time zone
   * (e.g., "America/Los_Angeles"). Falls back to UTC on invalid input.
   */
  async getCurrentStreakInTimeZone(
    userId: string,
    timeZone?: string,
  ): Promise<{ streak: number; lastMealDate?: string }> {
    const tz = this.validateTimeZone(timeZone);

    // Fetch only the fields we need, newest first
    const meals = await this.mealRepository.find({
      where: { userId },
      select: ['mealTime'],
      order: { mealTime: 'DESC' },
    });

    if (!meals.length) {
      return { streak: 0 };
    }

    // Build a set of ISO dates (YYYY-MM-DD) in the user's time zone
    const dateSet = new Set<string>();
    for (const m of meals) {
      if (!m.mealTime) continue;
      dateSet.add(this.getDateKeyInTimeZone(m.mealTime, tz));
    }

    if (dateSet.size === 0) {
      return { streak: 0 };
    }

    const todayKey = this.getKeyForDaysAgo(0, tz);
    const yKey = this.getKeyForDaysAgo(1, tz);

    // Determine starting point: if ate today, start from today; else if yesterday, start from yesterday; else streak is 0
    let daysAgo = 0;
    let streak = 0;

    if (dateSet.has(todayKey)) {
      streak = 1; // today counts as 1
    } else if (dateSet.has(yKey)) {
      daysAgo = 1;
      streak = 1; // yesterday counts as 1
    } else {
      return { streak: 0 };
    }

    // Walk backwards day by day while consecutive dates exist
    while (true) {
      const nextKey = this.getKeyForDaysAgo(daysAgo + 1, tz);
      if (dateSet.has(nextKey)) {
        streak += 1;
        daysAgo += 1;
      } else {
        break;
      }
    }

    const lastMealDate = [...dateSet].sort().pop();
    return { streak, lastMealDate };
  }

  private validateTimeZone(tz?: string): string {
    if (!tz) return 'UTC';
    try {
      new Intl.DateTimeFormat('en-US', { timeZone: tz }).format(new Date());
      return tz;
    } catch {
      return 'UTC';
    }
  }

  private getDateKeyInTimeZone(date: Date, timeZone: string): string {
    const fmt = new Intl.DateTimeFormat('en-CA', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    });
    const parts = fmt.formatToParts(date);
    const year = parts.find(p => p.type === 'year')?.value ?? '0000';
    const month = parts.find(p => p.type === 'month')?.value ?? '01';
    const day = parts.find(p => p.type === 'day')?.value ?? '01';
    return `${year}-${month}-${day}`;
  }

  private getKeyForDaysAgo(daysAgo: number, timeZone: string): string {
    // Determine the user's current local date first
    const now = new Date();
    const todayKey = this.getDateKeyInTimeZone(now, timeZone);
    const [y, m, d] = todayKey.split('-').map(Number);
    // Create a date at local midnight, then step back daysAgo
    const base = new Date(y, m - 1, d);
    const stepped = new Date(base.getTime() - daysAgo * 24 * 60 * 60 * 1000);
    return this.getDateKeyInTimeZone(stepped, timeZone);
  }
}
