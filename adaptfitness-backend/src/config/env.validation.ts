/**
 * Environment Validation
 * 
 * Validates that all required environment variables are present before starting the application.
 * This prevents runtime errors due to missing configuration.
 */

export function validateEnvironment() {
  const required = ['JWT_SECRET', 'DATABASE_PASSWORD'];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
  
  // Validate JWT_SECRET strength
  if (process.env.JWT_SECRET && process.env.JWT_SECRET.length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters long');
  }
}

