/**
 * Rate Limiting Configuration
 * 
 * Configures rate limiting to prevent abuse and brute force attacks.
 * 
 * Rate Limits:
 * - General API: 10 requests per minute per IP (production)
 * - Auth endpoints: 5 attempts per 15 minutes per IP (production)
 * 
 * Development: Higher limits for easier testing
 * Production: Stricter limits for security
 */

import { ThrottlerModuleOptions } from '@nestjs/throttler';

const isDevelopment = process.env.NODE_ENV === 'development';

/**
 * Global rate limiting configuration
 * Applied to all endpoints unless overridden
 */
export const throttlerConfig: ThrottlerModuleOptions = [
  {
    ttl: 60000,  // Time window in milliseconds (60 seconds = 1 minute)
    limit: isDevelopment ? 100 : 10,   // Higher limit in development for testing
  },
];

/**
 * Stricter rate limiting for authentication endpoints
 * Prevents brute force attacks on login/registration
 */
export const authThrottlerConfig = {
  ttl: isDevelopment ? 60000 : 900000,  // 1 minute in dev, 15 minutes in production
  limit: isDevelopment ? 50 : 5,         // 50 attempts per minute in dev, 5 per 15 min in production
};

