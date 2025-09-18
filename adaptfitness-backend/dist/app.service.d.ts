export declare class AppService {
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
