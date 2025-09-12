import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { MealService } from './meal.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('meals')
@UseGuards(JwtAuthGuard)
export class MealController {
  constructor(private mealService: MealService) {}

  @Post()
  async create(@Request() req, @Body() mealData: any) {
    return this.mealService.create({
      ...mealData,
      userId: req.user.id
    });
  }

  @Get()
  async findAll(@Request() req) {
    return this.mealService.findAll(req.user.id);
  }

  @Get(':id')
  async findOne(@Request() req, @Param('id') id: string) {
    return this.mealService.findOne(id, req.user.id);
  }

  @Put(':id')
  async update(@Request() req, @Param('id') id: string, @Body() updateData: any) {
    return this.mealService.update(id, req.user.id, updateData);
  }

  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    await this.mealService.remove(id, req.user.id);
    return { message: 'Meal deleted successfully' };
  }
}
