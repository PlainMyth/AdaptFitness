import { Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../../user/user.service';
interface JwtPayload {
    sub: string;
    email: string;
    iat: number;
    exp: number;
}
declare const JwtStrategy_base: new (...args: any[]) => Strategy;
export declare class JwtStrategy extends JwtStrategy_base {
    private userService;
    private configService;
    constructor(userService: UserService, configService: ConfigService);
    validate(payload: JwtPayload): Promise<import("../../user/user.entity").User>;
}
export {};
