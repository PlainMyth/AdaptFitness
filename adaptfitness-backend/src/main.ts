/**
 * Main Application Entry Point
 *
 * This is the starting point of the AdaptFitness API server.
 * It configures the NestJS application, sets up middleware,
 * and starts the server on the specified port.
 *
 * Key responsibilities:
 * - Initialize the NestJS application
 * - Configure CORS for frontend communication
 * - Set up global validation pipes for data validation
 * - Start the HTTP server
 * - Display startup information
 */

import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { validateEnvironment } from './config/env.validation';

/**
 * Bootstrap Function
 *
 * This function initializes and starts the AdaptFitness API server.
 * It's called when the application starts up.
 *
 * What it does:
 * 1. Creates the NestJS application instance
 * 2. Configures CORS for frontend communication
 * 3. Sets up global validation pipes for data validation
 * 4. Starts the server on the specified port
 * 5. Displays startup information
 */
async function bootstrap() {
  // Validate environment variables before starting the application
  validateEnvironment();
  
  // Create the NestJS application instance using our main AppModule
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS (Cross-Origin Resource Sharing) for frontend communication
  // This allows our frontend (iOS app, web app) to communicate with this API
  app.enableCors({
    // Allow requests from these origins (frontend URLs)
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000', 'http://localhost:8080'],
    // Allow cookies and authentication headers to be sent
    credentials: true,
  });
  
  // Set up global validation pipe for automatic data validation
  // Note: We use manual service-level validation instead of class-validator decorators
  // This provides more control and better error handling
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,        // Strip out properties not defined in DTOs
    forbidNonWhitelisted: true, // Throw error if unknown properties are sent
    transform: true,        // Automatically transform data types (string to number, etc.)
  }));
  
  // Get the port from environment variables or use default port 3000
  const port = process.env.PORT || 3000;
  
  // Start the server and listen for incoming requests
  await app.listen(port);
  
  // Display startup information
  console.log(`🚀 AdaptFitness API running on port ${port}`);
  console.log(`📱 Health check: http://localhost:${port}/health`);
}

// Start the application
bootstrap();
