/**
 * User Module
 *
 * This module configures all user-related components including the controller, service, and entity. It also sets up the database repository for user operations.
 *
 * Key responsibilities:
- Configure user-related components\n * - Set up database repository\n * - Register user services\n * - Export shared user utilities
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { UserService } from './user.service';
import { UserController } from './user.controller';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  providers: [UserService],
  controllers: [UserController],
  exports: [UserService],
})
export class UserModule {}
