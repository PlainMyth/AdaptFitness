import { UserService } from './user.service';
import { UpdateUserDto, UserResponseDto } from './dto/user.dto';
export declare class UserController {
    private userService;
    constructor(userService: UserService);
    getProfile(req: any): Promise<UserResponseDto>;
    updateProfile(req: any, updateUserDto: UpdateUserDto): Promise<UserResponseDto>;
    findOne(id: string): Promise<UserResponseDto>;
    findAll(): Promise<UserResponseDto[]>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
