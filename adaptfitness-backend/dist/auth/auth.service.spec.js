"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const auth_service_1 = require("./auth.service");
const user_service_1 = require("../user/user.service");
const jwt_1 = require("@nestjs/jwt");
const common_1 = require("@nestjs/common");
describe('AuthService', () => {
    let service;
    let userService;
    let jwtService;
    const mockUserService = {
        findByEmailForAuth: jest.fn(),
        findById: jest.fn(),
        create: jest.fn(),
    };
    const mockJwtService = {
        sign: jest.fn(),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [
                auth_service_1.AuthService,
                {
                    provide: user_service_1.UserService,
                    useValue: mockUserService,
                },
                {
                    provide: jwt_1.JwtService,
                    useValue: mockJwtService,
                },
            ],
        }).compile();
        service = module.get(auth_service_1.AuthService);
        userService = module.get(user_service_1.UserService);
        jwtService = module.get(jwt_1.JwtService);
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(service).toBeDefined();
    });
    describe('register', () => {
        const validRegisterDto = {
            email: 'test@example.com',
            password: 'SecurePass123!',
            firstName: 'John',
            lastName: 'Doe',
        };
        const mockUser = {
            id: '123',
            email: 'test@example.com',
            password: 'hashedPassword',
            firstName: 'John',
            lastName: 'Doe',
            isActive: true,
            createdAt: new Date(),
            updatedAt: new Date(),
        };
        it('should successfully register user with strong password', async () => {
            mockUserService.create.mockResolvedValue(mockUser);
            const result = await service.register(validRegisterDto);
            expect(result.message).toBe('User created successfully');
            expect(result.user.email).toBe(validRegisterDto.email);
            expect(result.user.firstName).toBe(validRegisterDto.firstName);
            expect(mockUserService.create).toHaveBeenCalled();
        });
        it('should reject password that is too short', async () => {
            const weakDto = { ...validRegisterDto, password: 'Short1!' };
            await expect(service.register(weakDto)).rejects.toThrow(common_1.BadRequestException);
        });
        it('should reject password without uppercase letter', async () => {
            const weakDto = { ...validRegisterDto, password: 'lowercase123!' };
            await expect(service.register(weakDto)).rejects.toThrow(common_1.BadRequestException);
        });
        it('should reject password without lowercase letter', async () => {
            const weakDto = { ...validRegisterDto, password: 'UPPERCASE123!' };
            await expect(service.register(weakDto)).rejects.toThrow(common_1.BadRequestException);
        });
        it('should reject password without number', async () => {
            const weakDto = { ...validRegisterDto, password: 'NoNumbers!' };
            await expect(service.register(weakDto)).rejects.toThrow(common_1.BadRequestException);
        });
        it('should reject password without special character', async () => {
            const weakDto = { ...validRegisterDto, password: 'NoSpecial123' };
            await expect(service.register(weakDto)).rejects.toThrow(common_1.BadRequestException);
        });
        it('should reject empty password', async () => {
            const weakDto = { ...validRegisterDto, password: '' };
            await expect(service.register(weakDto)).rejects.toThrow(common_1.BadRequestException);
        });
        it('should provide detailed error messages for weak password', async () => {
            const weakDto = { ...validRegisterDto, password: 'weak' };
            try {
                await service.register(weakDto);
                fail('Should have thrown BadRequestException');
            }
            catch (error) {
                expect(error).toBeInstanceOf(common_1.BadRequestException);
                const response = error.getResponse();
                expect(response.message).toBe('Password does not meet security requirements');
                expect(Array.isArray(response.errors)).toBe(true);
                expect(response.errors.length).toBeGreaterThan(0);
                expect(Array.isArray(response.requirements)).toBe(true);
            }
        });
        it('should hash password before storing', async () => {
            const createSpy = mockUserService.create.mockResolvedValue(mockUser);
            await service.register(validRegisterDto);
            const createCall = createSpy.mock.calls[0][0];
            expect(createCall.password).not.toBe(validRegisterDto.password);
            expect(createCall.password).toMatch(/^\$2[ab]\$/);
        });
        it('should not return password in response', async () => {
            mockUserService.create.mockResolvedValue(mockUser);
            const result = await service.register(validRegisterDto);
            expect(result.user).not.toHaveProperty('password');
        });
        it('should handle ConflictException from UserService', async () => {
            mockUserService.create.mockRejectedValue(new common_1.ConflictException('User with this email already exists'));
            await expect(service.register(validRegisterDto)).rejects.toThrow(common_1.ConflictException);
        });
        it('should accept various special characters', async () => {
            const specialChars = ['!', '@', '#', '$', '%', '^', '&', '*'];
            mockUserService.create.mockResolvedValue(mockUser);
            for (const char of specialChars) {
                const dto = { ...validRegisterDto, password: `SecurePass123${char}` };
                await expect(service.register(dto)).resolves.toBeDefined();
            }
        });
    });
    describe('Password Strength Edge Cases', () => {
        const baseDto = {
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
        };
        const mockUser = {
            id: '123',
            email: 'test@example.com',
            password: 'hashedPassword',
            firstName: 'John',
            lastName: 'Doe',
            isActive: true,
            createdAt: new Date(),
            updatedAt: new Date(),
        };
        beforeEach(() => {
            mockUserService.create.mockResolvedValue(mockUser);
        });
        it('should accept exactly 8 character password with all requirements', async () => {
            const dto = { ...baseDto, password: 'Abcd123!' };
            await expect(service.register(dto)).resolves.toBeDefined();
        });
        it('should accept very long password', async () => {
            const dto = { ...baseDto, password: 'ThisIsAVeryLongButSecurePassword123!@#' };
            await expect(service.register(dto)).resolves.toBeDefined();
        });
        it('should reject common weak passwords', async () => {
            const weakPasswords = [
                'password',
                'Password',
                'password123',
                'Password123',
                '12345678',
                'qwerty',
            ];
            for (const password of weakPasswords) {
                const dto = { ...baseDto, password };
                await expect(service.register(dto)).rejects.toThrow(common_1.BadRequestException);
            }
        });
    });
});
//# sourceMappingURL=auth.service.spec.js.map