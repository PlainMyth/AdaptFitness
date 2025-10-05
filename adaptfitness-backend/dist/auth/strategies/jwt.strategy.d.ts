import { Strategy } from 'passport-jwt';
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
    constructor(userService: UserService);
    validate(payload: JwtPayload): Promise<import("../../user/user.entity").User>;
}
export {};
