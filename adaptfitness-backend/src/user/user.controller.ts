/**
 * User Controller
 *
 * This controller handles all HTTP requests related to user management. It provides endpoints for user profile operations, user data retrieval, and user account management.
 *
 * Key responsibilities:
- Handle user profile operations\n * - Provide user data retrieval endpoints\n * - Manage user account settings\n * - Validate user permissions and data
 */

import { Controller, Get, Put, Delete, Body, Param, UseGuards, Request, Post } from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto, UserResponseDto } from './dto/user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private userService: UserService) {}

  @Get('profile')
  async getProfile(@Request() req): Promise<UserResponseDto> {
    const user = await this.userService.findById(req.user.id);
    return this.userService.toResponseDto(user);
  }

  @Put('profile')
  async updateProfile(@Request() req, @Body() updateUserDto: UpdateUserDto): Promise<UserResponseDto> {
    const user = await this.userService.update(req.user.id, updateUserDto);
    return this.userService.toResponseDto(user);
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserResponseDto> {
    const user = await this.userService.findById(id);
    if (!user) {
      throw new Error('User not found');
    }
    return this.userService.toResponseDto(user);
  }

  @Get()
  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.userService.findAll();
    return users.map(user => this.userService.toResponseDto(user));
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<{ message: string }> {
    await this.userService.delete(id);
    return { message: 'User deleted successfully' };
  }
}
