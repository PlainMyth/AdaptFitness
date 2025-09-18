import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, AuthResponseDto, RegisterResponseDto } from './dto/auth.dto';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    register(registerDto: RegisterDto): Promise<RegisterResponseDto>;
    login(loginDto: LoginDto): Promise<AuthResponseDto>;
    getProfile(req: any): Promise<{
        id: any;
        email: any;
        firstName: any;
        lastName: any;
        fullName: any;
        isActive: any;
    }>;
    validate(req: any): Promise<{
        valid: boolean;
        user: {
            id: any;
            email: any;
            firstName: any;
            lastName: any;
        };
    }>;
}
