/**
 * Rate Limiting Configuration
 * 
 * Configures rate limiting to prevent abuse and brute force attacks.
 * 
 * Rate Limits:
 * - General API: 10 requests per minute per IP
 * - Auth endpoints: 5 attempts per 15 minutes per IP
 */

import { ThrottlerModuleOptions } from '@nestjs/throttler';

/**
 * Global rate limiting configuration
 * Applied to all endpoints unless overridden
 */
export const throttlerConfig: ThrottlerModuleOptions = [
  {
    ttl: 60000,  // Time window in milliseconds (60 seconds = 1 minute)
    limit: 10,   // Max requests per time window
  },
];

/**
 * Stricter rate limiting for authentication endpoints
 * Prevents brute force attacks on login/registration
 */
export const authThrottlerConfig = {
  ttl: 900000,  // 15 minutes in milliseconds
  limit: 5,     // 5 attempts per 15 minutes
};

