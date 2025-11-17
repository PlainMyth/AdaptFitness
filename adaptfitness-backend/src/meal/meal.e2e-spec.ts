import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../app.module';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Meal } from './meal.entity';
import { User } from '../user/user.entity';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';

/**
 * Meal Tracker End-to-End Tests
 *
 * This file contains comprehensive E2E tests for the meal tracker functionality.
 * It tests the complete flow from HTTP request to database and back.
 *
 * Test coverage:
 * - Full CRUD operations with real database
 * - Authentication flow
 * - Food search integration
 * - Streak calculation
 * - Error handling
 * - Data validation
 */
describe('Meal Tracker E2E Tests', () => {
  let app: INestApplication;
  let mealRepository: Repository<Meal>;
  let userRepository: Repository<User>;
  let authToken: string;
  let testUserId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    await app.init();

    mealRepository = moduleFixture.get<Repository<Meal>>(getRepositoryToken(Meal));
    userRepository = moduleFixture.get<Repository<User>>(getRepositoryToken(User));

    // Create test user and get auth token
    const hashedPassword = await bcrypt.hash('TestPassword123!', 10);
    const testUser = userRepository.create({
      email: `test-meal-${Date.now()}@example.com`,
      password: hashedPassword,
      firstName: 'Test',
      lastName: 'User',
    });
    const savedUser = await userRepository.save(testUser);
    testUserId = savedUser.id;

    // Login to get token
    const loginResponse = await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: savedUser.email,
        password: 'TestPassword123!',
      });

    authToken = loginResponse.body.access_token;
  });

  afterAll(async () => {
    // Cleanup test data
    if (testUserId) {
      await mealRepository.delete({ user: { id: testUserId } });
      await userRepository.delete({ id: testUserId });
    }
    await app.close();
  });

  describe('POST /meals - Create Meal', () => {
    it('should create a meal successfully', async () => {
      const createMealDto = {
        name: 'Test Breakfast',
        description: 'A healthy breakfast',
        mealTime: new Date().toISOString(),
        totalCalories: 500,
        totalProtein: 30,
        totalCarbs: 50,
        totalFat: 20,
        mealType: 'breakfast',
      };

      const response = await request(app.getHttpServer())
        .post('/meals')
        .set('Authorization', `Bearer ${authToken}`)
        .send(createMealDto)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.name).toBe(createMealDto.name);
      expect(response.body.totalCalories).toBe(createMealDto.totalCalories);
      expect(response.body.userId).toBe(testUserId);
    });

    it('should reject meal creation without authentication', async () => {
      const createMealDto = {
        name: 'Test Meal',
        totalCalories: 500,
      };

      await request(app.getHttpServer())
        .post('/meals')
        .send(createMealDto)
        .expect(401);
    });

    it('should validate required fields', async () => {
      const invalidMealDto = {
        // Missing required fields
        description: 'Test',
      };

      await request(app.getHttpServer())
        .post('/meals')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidMealDto)
        .expect(400);
    });
  });

  describe('GET /meals - Get All Meals', () => {
    let createdMealId: string;

    beforeEach(async () => {
      // Create a test meal
      const meal = mealRepository.create({
        name: 'Test Meal for List',
        mealTime: new Date(),
        totalCalories: 600,
        user: { id: testUserId } as User,
      });
      const savedMeal = await mealRepository.save(meal);
      createdMealId = savedMeal.id;
    });

    afterEach(async () => {
      if (createdMealId) {
        await mealRepository.delete({ id: createdMealId });
      }
    });

    it('should return all meals for authenticated user', async () => {
      const response = await request(app.getHttpServer())
        .get('/meals')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
      expect(response.body[0]).toHaveProperty('id');
      expect(response.body[0]).toHaveProperty('name');
    });

    it('should return empty array for user with no meals', async () => {
      // Create a new user with no meals
      const hashedPassword = await bcrypt.hash('TestPassword123!', 10);
      const newUser = userRepository.create({
        email: `test-empty-${Date.now()}@example.com`,
        password: hashedPassword,
        firstName: 'Empty',
        lastName: 'User',
      });
      const savedUser = await userRepository.save(newUser);

      const loginResponse = await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: savedUser.email,
          password: 'TestPassword123!',
        });

      const newToken = loginResponse.body.access_token;

      const response = await request(app.getHttpServer())
        .get('/meals')
        .set('Authorization', `Bearer ${newToken}`)
        .expect(200);

      expect(response.body).toEqual([]);

      // Cleanup
      await userRepository.delete({ id: savedUser.id });
    });

    it('should reject request without authentication', async () => {
      await request(app.getHttpServer())
        .get('/meals')
        .expect(401);
    });
  });

  describe('GET /meals/:id - Get Single Meal', () => {
    let createdMealId: string;

    beforeEach(async () => {
      const meal = mealRepository.create({
        name: 'Test Meal for Get',
        mealTime: new Date(),
        totalCalories: 700,
        user: { id: testUserId } as User,
      });
      const savedMeal = await mealRepository.save(meal);
      createdMealId = savedMeal.id;
    });

    afterEach(async () => {
      if (createdMealId) {
        await mealRepository.delete({ id: createdMealId });
      }
    });

    it('should return a meal by id', async () => {
      const response = await request(app.getHttpServer())
        .get(`/meals/${createdMealId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.id).toBe(createdMealId);
      expect(response.body.name).toBe('Test Meal for Get');
    });

    it('should return 404 for non-existent meal', async () => {
      const fakeId = '00000000-0000-0000-0000-000000000000';
      await request(app.getHttpServer())
        .get(`/meals/${fakeId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('PUT /meals/:id - Update Meal', () => {
    let createdMealId: string;

    beforeEach(async () => {
      const meal = mealRepository.create({
        name: 'Original Meal',
        mealTime: new Date(),
        totalCalories: 500,
        user: { id: testUserId } as User,
      });
      const savedMeal = await mealRepository.save(meal);
      createdMealId = savedMeal.id;
    });

    afterEach(async () => {
      if (createdMealId) {
        await mealRepository.delete({ id: createdMealId });
      }
    });

    it('should update a meal successfully', async () => {
      const updateDto = {
        name: 'Updated Meal',
        totalCalories: 600,
      };

      const response = await request(app.getHttpServer())
        .put(`/meals/${createdMealId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateDto)
        .expect(200);

      expect(response.body.name).toBe('Updated Meal');
      expect(response.body.totalCalories).toBe(600);
    });
  });

  describe('DELETE /meals/:id - Delete Meal', () => {
    let createdMealId: string;

    beforeEach(async () => {
      const meal = mealRepository.create({
        name: 'Meal to Delete',
        mealTime: new Date(),
        totalCalories: 500,
        user: { id: testUserId } as User,
      });
      const savedMeal = await mealRepository.save(meal);
      createdMealId = savedMeal.id;
    });

    it('should delete a meal successfully', async () => {
      await request(app.getHttpServer())
        .delete(`/meals/${createdMealId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      // Verify meal is deleted
      const response = await request(app.getHttpServer())
        .get(`/meals/${createdMealId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('GET /meals/streak/current - Get Streak', () => {
    beforeEach(async () => {
      // Create meals for streak testing
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);

      await mealRepository.save([
        mealRepository.create({
          name: 'Today Meal',
          mealTime: today,
          totalCalories: 500,
          user: { id: testUserId } as User,
        }),
        mealRepository.create({
          name: 'Yesterday Meal',
          mealTime: yesterday,
          totalCalories: 600,
          user: { id: testUserId } as User,
        }),
      ]);
    });

    it('should return current streak', async () => {
      const response = await request(app.getHttpServer())
        .get('/meals/streak/current')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('streak');
      expect(response.body).toHaveProperty('lastMealDate');
      expect(typeof response.body.streak).toBe('number');
      expect(response.body.streak).toBeGreaterThanOrEqual(0);
    });

    it('should handle timezone parameter', async () => {
      const response = await request(app.getHttpServer())
        .get('/meals/streak/current?tz=America/New_York')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('streak');
      expect(response.body).toHaveProperty('lastMealDate');
    });
  });

  describe('GET /meals/foods/search - Food Search', () => {
    it('should search for foods successfully', async () => {
      const response = await request(app.getHttpServer())
        .get('/meals/foods/search?query=apple&page=1&pageSize=20')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('foods');
      expect(response.body).toHaveProperty('totalCount');
      expect(response.body).toHaveProperty('page');
      expect(response.body).toHaveProperty('pageSize');
      expect(Array.isArray(response.body.foods)).toBe(true);
    });

    it('should handle empty search query', async () => {
      await request(app.getHttpServer())
        .get('/meals/foods/search?query=&page=1&pageSize=20')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(400);
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .get('/meals/foods/search?query=apple')
        .expect(401);
    });
  });
});

