import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'AdaptFitness API',
      version: '1.0.0',
    };
  }

  getWelcome() {
    return {
      message: 'Welcome to AdaptFitness API',
      description: 'A fitness app that redefines functionality and ease of getting into fitness!',
      version: '1.0.0',
      endpoints: {
        health: '/health',
        auth: '/auth',
        users: '/users',
        workouts: '/workouts',
        meals: '/meals',
      },
    };
  }
}
