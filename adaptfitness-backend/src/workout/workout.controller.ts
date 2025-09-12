import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { WorkoutService } from './workout.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('workouts')
@UseGuards(JwtAuthGuard)
export class WorkoutController {
  constructor(private workoutService: WorkoutService) {}

  @Post()
  async create(@Request() req, @Body() workoutData: any) {
    return this.workoutService.create({
      ...workoutData,
      userId: req.user.id
    });
  }

  @Get()
  async findAll(@Request() req) {
    return this.workoutService.findAll(req.user.id);
  }

  @Get(':id')
  async findOne(@Request() req, @Param('id') id: string) {
    return this.workoutService.findOne(id, req.user.id);
  }

  @Put(':id')
  async update(@Request() req, @Param('id') id: string, @Body() updateData: any) {
    return this.workoutService.update(id, req.user.id, updateData);
  }

  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    await this.workoutService.remove(id, req.user.id);
    return { message: 'Workout deleted successfully' };
  }
}
