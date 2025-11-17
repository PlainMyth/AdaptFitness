// Test setup file for E2E tests
import { execSync } from 'child_process';

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-key';
process.env.DATABASE_HOST = process.env.TEST_DATABASE_HOST || 'localhost';
process.env.DATABASE_PORT = process.env.TEST_DATABASE_PORT || '5432';
process.env.DATABASE_USERNAME = process.env.TEST_DATABASE_USERNAME || 'postgres';
process.env.DATABASE_PASSWORD = process.env.TEST_DATABASE_PASSWORD || '1234';
process.env.DATABASE_NAME = process.env.TEST_DATABASE_NAME || 'adaptfitness';

// Global test timeout
jest.setTimeout(30000);

// Setup and teardown for database
beforeAll(async () => {
  // Any global setup can go here
  console.log('Setting up E2E test environment...');
  console.log('DATABASE_PASSWORD:', process.env.DATABASE_PASSWORD);
  console.log('DATABASE_NAME:', process.env.DATABASE_NAME);
});

afterAll(async () => {
  // Any global cleanup can go here
  console.log('Cleaning up E2E test environment...');
});
