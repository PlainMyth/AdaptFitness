import { Repository } from 'typeorm';
import { User } from './user.entity';
import { CreateUserDto, UpdateUserDto, UserResponseDto } from './dto/user.dto';
export declare class UserService {
    private userRepository;
    constructor(userRepository: Repository<User>);
    create(createUserDto: CreateUserDto): Promise<User>;
    findByEmail(email: string): Promise<User | undefined>;
    findById(id: string): Promise<User | undefined>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    delete(id: string): Promise<void>;
    findAll(): Promise<User[]>;
    toResponseDto(user: User): UserResponseDto;
}
