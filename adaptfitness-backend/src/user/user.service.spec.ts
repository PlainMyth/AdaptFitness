/**
 * User Service Tests
 * 
 * Tests for UserService focusing on password security and data retrieval.
 */

import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserService } from './user.service';
import { User } from './user.entity';
import { ConflictException, NotFoundException } from '@nestjs/common';

describe('UserService', () => {
  let service: UserService;
  let repository: Repository<User>;

  // Mock user data
  const mockUser = {
    id: '123',
    email: 'test@example.com',
    password: 'hashedPassword123',
    firstName: 'John',
    lastName: 'Doe',
    dateOfBirth: new Date('1990-01-01'),
    height: 180,
    weight: 75,
    gender: 'male',
    activityLevel: 'moderate',
    activityLevelMultiplier: 1.55,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    fullName: 'John Doe',
    age: 33,
    bmi: 23.15,
  };

  // Mock user without password (for safe queries)
  const mockUserWithoutPassword = {
    id: '123',
    email: 'test@example.com',
    firstName: 'John',
    lastName: 'Doe',
    dateOfBirth: new Date('1990-01-01'),
    height: 180,
    weight: 75,
    gender: 'male',
    activityLevel: 'moderate',
    activityLevelMultiplier: 1.55,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
            delete: jest.fn(),
            find: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findByEmailForAuth', () => {
    it('should return user WITH password for authentication', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUser as User);

      const result = await service.findByEmailForAuth('test@example.com');

      expect(result).toBeDefined();
      expect(result.password).toBe('hashedPassword123');
      expect(result.email).toBe('test@example.com');
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { email: 'test@example.com' },
      });
    });

    it('should return null if user not found', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(null);

      const result = await service.findByEmailForAuth('nonexistent@example.com');

      expect(result).toBeNull();
    });
  });

  describe('findByEmail', () => {
    it('should return user WITHOUT password for general use', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUserWithoutPassword as User);

      const result = await service.findByEmail('test@example.com');

      expect(result).toBeDefined();
      expect(result.password).toBeUndefined();
      expect(result.email).toBe('test@example.com');
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { email: 'test@example.com' },
        select: expect.arrayContaining(['id', 'email', 'firstName', 'lastName']),
      });
    });

    it('should not include password in select fields', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUserWithoutPassword as User);

      await service.findByEmail('test@example.com');

      const call = (repository.findOne as jest.Mock).mock.calls[0][0];
      expect(call.select).toBeDefined();
      expect(call.select).not.toContain('password');
    });
  });

  describe('findByIdForAuth', () => {
    it('should return user WITH password for authentication', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUser as User);

      const result = await service.findByIdForAuth('123');

      expect(result).toBeDefined();
      expect(result.password).toBe('hashedPassword123');
      expect(result.id).toBe('123');
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { id: '123' },
      });
    });

    it('should return null if user not found', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(null);

      const result = await service.findByIdForAuth('nonexistent-id');

      expect(result).toBeNull();
    });
  });

  describe('findById', () => {
    it('should return user WITHOUT password for general use', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUserWithoutPassword as User);

      const result = await service.findById('123');

      expect(result).toBeDefined();
      expect(result.password).toBeUndefined();
      expect(result.id).toBe('123');
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { id: '123' },
        select: expect.arrayContaining(['id', 'email', 'firstName', 'lastName']),
      });
    });

    it('should not include password in select fields', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUserWithoutPassword as User);

      await service.findById('123');

      const call = (repository.findOne as jest.Mock).mock.calls[0][0];
      expect(call.select).toBeDefined();
      expect(call.select).not.toContain('password');
    });
  });

  describe('create', () => {
    it('should create a new user', async () => {
      const createUserDto = {
        email: 'newuser@example.com',
        password: 'hashedPassword',
        firstName: 'Jane',
        lastName: 'Smith',
      };

      jest.spyOn(repository, 'findOne').mockResolvedValue(null);
      jest.spyOn(repository, 'create').mockReturnValue(mockUser as User);
      jest.spyOn(repository, 'save').mockResolvedValue(mockUser as User);

      const result = await service.create(createUserDto);

      expect(result).toBeDefined();
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { email: createUserDto.email },
      });
      expect(repository.create).toHaveBeenCalledWith(createUserDto);
      expect(repository.save).toHaveBeenCalled();
    });

    it('should throw ConflictException if email already exists', async () => {
      const createUserDto = {
        email: 'existing@example.com',
        password: 'hashedPassword',
        firstName: 'Jane',
        lastName: 'Smith',
      };

      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUser as User);

      await expect(service.create(createUserDto)).rejects.toThrow(ConflictException);
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { email: createUserDto.email },
      });
    });
  });

  describe('update', () => {
    it('should update a user', async () => {
      const updateDto = { firstName: 'Updated' };
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUserWithoutPassword as User);
      jest.spyOn(repository, 'save').mockResolvedValue({
        ...mockUserWithoutPassword,
        firstName: 'Updated',
      } as User);

      const result = await service.update('123', updateDto);

      expect(result.firstName).toBe('Updated');
      expect(repository.save).toHaveBeenCalled();
    });

    it('should throw NotFoundException if user not found', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(null);

      await expect(service.update('nonexistent', { firstName: 'Test' })).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('delete', () => {
    it('should delete a user', async () => {
      jest.spyOn(repository, 'delete').mockResolvedValue({ affected: 1, raw: {} });

      await service.delete('123');

      expect(repository.delete).toHaveBeenCalledWith('123');
    });

    it('should throw NotFoundException if user not found', async () => {
      jest.spyOn(repository, 'delete').mockResolvedValue({ affected: 0, raw: {} });

      await expect(service.delete('nonexistent')).rejects.toThrow(NotFoundException);
    });
  });

  describe('findAll', () => {
    it('should return all users WITHOUT passwords', async () => {
      const users = [mockUserWithoutPassword, mockUserWithoutPassword];
      jest.spyOn(repository, 'find').mockResolvedValue(users as User[]);

      const result = await service.findAll();

      expect(result).toHaveLength(2);
      expect(repository.find).toHaveBeenCalledWith({
        select: expect.not.arrayContaining(['password']),
      });
    });
  });

  describe('Password Security Tests', () => {
    it('ForAuth methods should include password field', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUser as User);

      const emailResult = await service.findByEmailForAuth('test@example.com');
      const idResult = await service.findByIdForAuth('123');

      expect(emailResult.password).toBeDefined();
      expect(idResult.password).toBeDefined();
    });

    it('Regular methods should NOT include password field', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(mockUserWithoutPassword as User);

      const emailResult = await service.findByEmail('test@example.com');
      const idResult = await service.findById('123');

      expect(emailResult.password).toBeUndefined();
      expect(idResult.password).toBeUndefined();
    });
  });
});

