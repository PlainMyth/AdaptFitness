/**
 * JWT Authentication Strategy
 *
 * This strategy handles JWT token validation for Passport authentication. It extracts JWT tokens from the Authorization header, validates them, and returns user information if the token is valid.
 *
 * Key responsibilities:
 * - Extract JWT tokens from HTTP requests
 * - Validate token signature and expiration
 * - Verify user exists and is active
 * - Return user data for authenticated requests
 */

import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../../user/user.service';

interface JwtPayload {
  sub: string;
  email: string;
  iat: number;
  exp: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private userService: UserService,
    private configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: JwtPayload) {
    try {
      // Use regular findById - we don't need password for JWT validation
      // This prevents password leakage in authenticated requests
      const user = await this.userService.findById(payload.sub);
      if (!user || !user.isActive) {
        return null;
      }
      return user;
    } catch (error) {
      return null;
    }
  }
}
