/**
 * Main Application Service
 *
 * This service provides basic application functionality and information.
 * It handles the business logic for root-level endpoints like health checks
 * and welcome messages.
 *
 * Key responsibilities:
 * - Provide health status information
 * - Generate welcome messages and API documentation
 * - Serve as the main service for basic app operations
 */

import { Injectable } from '@nestjs/common';

// @Injectable decorator makes this class available for dependency injection
@Injectable()
export class AppService {
  /**
   * Get Health Status
   *
   * Returns the current health status of the API service.
   * This is used by monitoring tools, load balancers, and health check systems.
   *
   * What it returns:
   * - Current status (always 'ok' if the service is running)
   * - Timestamp of when the check was performed
   * - Service name and version information
   *
   * @returns Object containing health status information
   */
  getHealth() {
    return {
      status: 'ok',                                    // Service is running and healthy
      timestamp: new Date().toISOString(),            // Current timestamp in ISO format
      service: 'AdaptFitness API',                    // Name of the service
      version: '1.0.0',                               // Current API version
    };
  }

  /**
   * Get Welcome Message
   *
   * Returns a welcome message and basic API information for new users or developers.
   * This provides an overview of what the API does and what endpoints are available.
   *
   * What it returns:
   * - Welcome message and description
   * - API version information
   * - List of available endpoint categories
   *
   * @returns Object containing welcome message and API information
   */
  getWelcome() {
    return {
      message: 'Welcome to AdaptFitness API',         // Main welcome message
      description: 'A fitness app that redefines functionality and ease of getting into fitness!', // App description
      version: '1.0.0',                               // Current API version
      endpoints: {                                    // Available API endpoint categories
        health: '/health',                            // Health check endpoint
        auth: '/auth',                                // Authentication endpoints
        users: '/users',                              // User management endpoints
        workouts: '/workouts',                        // Workout tracking endpoints
        meals: '/meals',                              // Meal logging endpoints
        'health-metrics': '/health-metrics',          // Health metrics endpoints
      },
    };
  }
}
