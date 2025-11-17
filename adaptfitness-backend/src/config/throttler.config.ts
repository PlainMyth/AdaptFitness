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
 * Localhost: Very lenient limits for local development
 */

import { ThrottlerModuleOptions } from '@nestjs/throttler';

const isDevelopment = process.env.NODE_ENV === 'development';
// For localhost, be very lenient with rate limiting
const isLocalhost = process.env.PORT === '3000' || !process.env.PORT;

/**
 * Global rate limiting configuration
 * Applied to all endpoints unless overridden
 */
export const throttlerConfig: ThrottlerModuleOptions = [
  {
    ttl: 60000,  // Time window in milliseconds (60 seconds = 1 minute)
    limit: isLocalhost ? 1000 : isDevelopment ? 100 : 10,   // Very high limit for localhost, higher for dev, normal for production
  },
];

/**
 * Stricter rate limiting for authentication endpoints
 * Prevents brute force attacks on login/registration
 */
export const authThrottlerConfig = {
  ttl: isLocalhost ? 60000 : isDevelopment ? 60000 : 900000,  // 1 minute for localhost/dev, 15 minutes in production
  limit: isLocalhost ? 200 : isDevelopment ? 50 : 5,         // 200 attempts per minute for localhost, 50 for dev, 5 per 15 min for production
};

