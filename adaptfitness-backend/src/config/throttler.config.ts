/**
 * Rate Limiting Configuration
 * 
 * Configures rate limiting to prevent abuse and brute force attacks.
 * 
 * Rate Limits:
 * - General API: 50 requests per minute per IP (production)
 * - Auth endpoints: 100 attempts per 60 minutes per IP (production)
 * 
 * Development: Higher limits for easier testing
 * Production: More lenient limits for better user experience
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
    limit: isLocalhost ? 1000 : isDevelopment ? 200 : 50,   // Very high limit for localhost, higher for dev, increased for production
  },
];

/**
 * Rate limiting for authentication endpoints
 * Prevents brute force attacks while allowing reasonable usage
 * Increased limits and time windows to reduce sensitivity to rapid clicking
 */
export const authThrottlerConfig = {
  ttl: isLocalhost ? 300000 : isDevelopment ? 300000 : 3600000,  // 5 minutes for localhost, 5 minutes for dev, 60 minutes (1 hour) in production
  limit: isLocalhost ? 1000 : isDevelopment ? 300 : 100,       // 1000 attempts per 5 min for localhost, 300 per 5 min for dev, 100 per 60 min for production
};

