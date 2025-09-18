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
    console.log('JwtAuthGuard canActivate called');
    return super.canActivate(context);
  }
}
