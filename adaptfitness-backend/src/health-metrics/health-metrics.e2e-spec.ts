import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import request from 'supertest';
import { HealthMetricsModule } from './health-metrics.module';
import { UserModule } from '../user/user.module';
import { AuthModule } from '../auth/auth.module';
import { HealthMetrics } from './health-metrics.entity';
import { User } from '../user/user.entity';

describe('HealthMetrics (e2e)', () => {
  let app: INestApplication;
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          envFilePath: '.env.test',
        }),
        TypeOrmModule.forRoot({
          type: 'postgres',
          host: process.env.TEST_DATABASE_HOST || 'localhost',
          port: parseInt(process.env.TEST_DATABASE_PORT || '5432'),
          username: process.env.TEST_DATABASE_USERNAME || 'postgres',
          password: process.env.TEST_DATABASE_PASSWORD || 'password',
          database: process.env.TEST_DATABASE_NAME || 'adaptfitness_test',
          entities: [HealthMetrics, User],
          synchronize: true, // Only for testing
          dropSchema: true, // Clean database for each test
        }),
        PassportModule.register({ defaultStrategy: 'jwt' }),
        JwtModule.register({
          secret: process.env.JWT_SECRET || 'test-secret',
          signOptions: { expiresIn: '1h' },
        }),
        AuthModule,
        UserModule,
        HealthMetricsModule,
      ],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Create a test user and get auth token
    const userResponse = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        email: 'test@example.com',
        password: 'password123',
        firstName: 'Test',
        lastName: 'User',
        dateOfBirth: '1995-01-01',
        height: 175,
        gender: 'male',
        activityLevel: 'moderately_active',
        activityLevelMultiplier: 1.55,
      });

    authToken = userResponse.body.access_token;
    userId = userResponse.body.user.id;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('/health-metrics (POST)', () => {
    it('should create health metrics', () => {
      const createHealthMetricsDto = {
        currentWeight: 70,
        bodyFatPercentage: 15,
        goalWeight: 65,
        waistCircumference: 80,
        hipCircumference: 95,
        chestCircumference: 100,
        thighCircumference: 60,
        armCircumference: 35,
        neckCircumference: 40,
        notes: 'Test measurement',
      };

      return request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send(createHealthMetricsDto)
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body).toHaveProperty('userId', userId);
          expect(res.body).toHaveProperty('currentWeight', 70);
          expect(res.body).toHaveProperty('bmi');
          expect(res.body).toHaveProperty('leanBodyMass');
          expect(res.body).toHaveProperty('tdee');
          expect(res.body).toHaveProperty('rmr');
          expect(res.body).toHaveProperty('waistToHipRatio');
          expect(res.body).toHaveProperty('waistToHeightRatio');
          expect(res.body).toHaveProperty('absi');
        });
    });

    it('should return 400 for invalid data', () => {
      const invalidDto = {
        currentWeight: -10, // Invalid negative weight
        bodyFatPercentage: 150, // Invalid percentage > 100
      };

      return request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidDto)
        .expect(400);
    });

    it('should return 401 without authentication', () => {
      return request(app.getHttpServer())
        .post('/health-metrics')
        .send({ currentWeight: 70 })
        .expect(401);
    });
  });

  describe('/health-metrics (GET)', () => {
    it('should return all health metrics for user', async () => {
      // Create multiple health metrics
      await request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 70, notes: 'First measurement' });

      await request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 69, notes: 'Second measurement' });

      return request(app.getHttpServer())
        .get('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.length).toBeGreaterThanOrEqual(2);
          expect(res.body[0]).toHaveProperty('id');
          expect(res.body[0]).toHaveProperty('userId', userId);
        });
    });
  });

  describe('/health-metrics/latest (GET)', () => {
    it('should return the latest health metrics', () => {
      return request(app.getHttpServer())
        .get('/health-metrics/latest')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body).toHaveProperty('userId', userId);
          expect(res.body).toHaveProperty('currentWeight');
          expect(res.body).toHaveProperty('bmi');
        });
    });
  });

  describe('/health-metrics/calculations (GET)', () => {
    it('should return calculated metrics', () => {
      return request(app.getHttpServer())
        .get('/health-metrics/calculations')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('bmi');
          expect(res.body).toHaveProperty('tdee');
          expect(res.body).toHaveProperty('rmr');
          expect(res.body).toHaveProperty('bodyFatCategory');
          expect(res.body).toHaveProperty('bmiCategory');
        });
    });
  });

  describe('/health-metrics/:id (GET)', () => {
    let healthMetricId: number;

    beforeEach(async () => {
      const response = await request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 70, notes: 'Test for GET' });

      healthMetricId = response.body.id;
    });

    it('should return a specific health metric', () => {
      return request(app.getHttpServer())
        .get(`/health-metrics/${healthMetricId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('id', healthMetricId);
          expect(res.body).toHaveProperty('userId', userId);
          expect(res.body).toHaveProperty('currentWeight', 70);
        });
    });

    it('should return 404 for non-existent health metric', () => {
      return request(app.getHttpServer())
        .get('/health-metrics/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('/health-metrics/:id (PATCH)', () => {
    let healthMetricId: number;

    beforeEach(async () => {
      const response = await request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 70, notes: 'Test for PATCH' });

      healthMetricId = response.body.id;
    });

    it('should update health metrics', () => {
      const updateDto = {
        currentWeight: 68,
        notes: 'Updated measurement',
      };

      return request(app.getHttpServer())
        .patch(`/health-metrics/${healthMetricId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateDto)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('id', healthMetricId);
          expect(res.body).toHaveProperty('currentWeight', 68);
          expect(res.body).toHaveProperty('notes', 'Updated measurement');
          expect(res.body).toHaveProperty('bmi'); // Should recalculate
        });
    });

    it('should return 404 for non-existent health metric', () => {
      return request(app.getHttpServer())
        .patch('/health-metrics/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 68 })
        .expect(404);
    });
  });

  describe('/health-metrics/:id (DELETE)', () => {
    let healthMetricId: number;

    beforeEach(async () => {
      const response = await request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 70, notes: 'Test for DELETE' });

      healthMetricId = response.body.id;
    });

    it('should delete health metrics', () => {
      return request(app.getHttpServer())
        .delete(`/health-metrics/${healthMetricId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
    });

    it('should return 404 for non-existent health metric', () => {
      return request(app.getHttpServer())
        .delete('/health-metrics/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('Data Validation', () => {
    it('should validate body fat percentage range', () => {
      return request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentWeight: 70,
          bodyFatPercentage: 150, // Invalid: > 100
        })
        .expect(400);
    });

    it('should validate weight is positive', () => {
      return request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentWeight: -10, // Invalid: negative
        })
        .expect(400);
    });
  });

  describe('User Isolation', () => {
    let otherUserToken: string;
    let otherUserId: string;

    beforeAll(async () => {
      // Create another test user
      const userResponse = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          email: 'other@example.com',
          password: 'password123',
          firstName: 'Other',
          lastName: 'User',
          dateOfBirth: '1990-01-01',
          height: 180,
          gender: 'female',
          activityLevel: 'lightly_active',
          activityLevelMultiplier: 1.375,
        });

      otherUserToken = userResponse.body.access_token;
      otherUserId = userResponse.body.user.id;
    });

    it('should not allow access to other user\'s health metrics', async () => {
      // Create health metrics for the first user
      const response = await request(app.getHttpServer())
        .post('/health-metrics')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ currentWeight: 70, notes: 'First user data' });

      const healthMetricId = response.body.id;

      // Try to access with second user's token
      return request(app.getHttpServer())
        .get(`/health-metrics/${healthMetricId}`)
        .set('Authorization', `Bearer ${otherUserToken}`)
        .expect(404);
    });
  });
});
