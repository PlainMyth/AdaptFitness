/**
 * Main Application Controller
 *
 * This controller handles the root-level API endpoints for the AdaptFitness application.
 * It provides basic application information and health check functionality.
 *
 * Key responsibilities:
 * - Provide health check endpoint for monitoring
 * - Display welcome message and API information
 * - Serve as the main entry point for basic app queries
 */

import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

// @Controller decorator with no prefix means this handles root-level routes
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  /**
   * GET /health
   *
   * Health check endpoint for monitoring and load balancers
   *
   * What it does:
   * 1. Returns the current status of the API
   * 2. Provides service information and version
   * 3. Used by monitoring tools to check if the API is running
   *
   * Returns: Object with status, service name, and version
   *
   * Example response:
   * {
   *   "status": "ok",
   *   "service": "AdaptFitness API",
   *   "version": "1.0.0"
   * }
   */
  @Get('health')
  getHealth() {
    return this.appService.getHealth();
  }

  /**
   * GET /
   *
   * Welcome endpoint that provides API information
   *
   * What it does:
   * 1. Returns a welcome message
   * 2. Lists available API endpoints
   * 3. Provides basic API documentation
   *
   * Returns: Object with welcome message and endpoint information
   *
   * Example response:
   * {
   *   "message": "Welcome to AdaptFitness API",
   *   "endpoints": {
   *     "health": "GET /health",
   *     "auth": "POST /auth/login, POST /auth/register",
   *     "users": "GET /users, PUT /users/profile",
   *     "workouts": "GET /workouts, POST /workouts",
   *     "meals": "GET /meals, POST /meals",
   *     "health-metrics": "GET /health-metrics, POST /health-metrics"
   *   }
   * }
   */
  @Get()
  getWelcome() {
    return this.appService.getWelcome();
  }
}
