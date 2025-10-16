import { ThrottlerModuleOptions } from '@nestjs/throttler';
export declare const throttlerConfig: ThrottlerModuleOptions;
export declare const authThrottlerConfig: {
    ttl: number;
    limit: number;
};
