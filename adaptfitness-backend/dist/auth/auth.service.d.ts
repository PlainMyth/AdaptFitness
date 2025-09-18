import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import { RegisterDto, LoginDto, AuthResponseDto, RegisterResponseDto } from './dto/auth.dto';
export declare class AuthService {
    private userService;
    private jwtService;
    constructor(userService: UserService, jwtService: JwtService);
    validateUser(email: string, password: string): Promise<any>;
    login(loginDto: LoginDto): Promise<AuthResponseDto>;
    register(registerDto: RegisterDto): Promise<RegisterResponseDto>;
    validateToken(userId: string): Promise<any>;
}
