/**
 * JWT Authentication Strategy
 *
 * This strategy handles JWT token validation for Passport authentication. It extracts JWT tokens from the Authorization header, validates them, and returns user information if the token is valid.
 *
 * Key responsibilities:
- Extract JWT tokens from HTTP requests\n * - Validate token signature and expiration\n * - Verify user exists and is active\n * - Return user data for authenticated requests
 */

import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UserService } from '../../user/user.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private userService: UserService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production-adaptfitness-2024',
    });
  }

  async validate(payload: any) {
    console.log('🔐 JWT Strategy validate called with payload:', payload);
    try {
      const user = await this.userService.findById(payload.sub);
      if (!user) {
        console.log('❌ User not found for ID:', payload.sub);
        return null;
      }
      if (!user.isActive) {
        console.log('❌ User is inactive:', user.email);
        return null;
      }
      console.log('✅ User validated successfully:', user.email);
      return user;
    } catch (error) {
      console.log('❌ JWT validation error:', error.message);
      return null;
    }
  }
}
