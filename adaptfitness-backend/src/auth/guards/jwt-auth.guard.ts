/**
 * JWT Authentication Guard
 *
 * This guard protects routes by requiring a valid JWT token. It uses the JWT strategy to validate tokens and ensure only authenticated users can access protected endpoints.
 *
 * Key responsibilities:
- Protect routes that require authentication\n * - Validate JWT tokens using the JWT strategy\n * - Reject requests with invalid or missing tokens\n * - Allow authenticated users to access protected resources
 */

import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    // Debug logging only in development mode
    if (process.env.NODE_ENV === 'development') {
      // Avoid logging in production to prevent unnecessary noise
    }
    return super.canActivate(context);
  }
}
