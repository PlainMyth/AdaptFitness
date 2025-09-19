import { AppService } from './app.service';
export declare class AppController {
    private readonly appService;
    constructor(appService: AppService);
    getHealth(): {
        status: string;
        timestamp: string;
        service: string;
        version: string;
    };
    getWelcome(): {
        message: string;
        description: string;
        version: string;
        endpoints: {
            health: string;
            auth: string;
            users: string;
            workouts: string;
            meals: string;
            'health-metrics': string;
        };
    };
}
