"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("./user.entity");
let UserService = class UserService {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }
    async create(createUserDto) {
        const existingUser = await this.userRepository.findOne({
            where: { email: createUserDto.email }
        });
        if (existingUser) {
            throw new common_1.ConflictException('User with this email already exists');
        }
        const user = this.userRepository.create(createUserDto);
        return this.userRepository.save(user);
    }
    async findByEmailForAuth(email) {
        return this.userRepository.findOne({ where: { email } });
    }
    async findByEmail(email) {
        return this.userRepository.findOne({
            where: { email },
            select: ['id', 'email', 'firstName', 'lastName', 'dateOfBirth', 'height', 'weight', 'gender', 'activityLevel', 'activityLevelMultiplier', 'isActive', 'createdAt', 'updatedAt']
        });
    }
    async findByIdForAuth(id) {
        return this.userRepository.findOne({ where: { id } });
    }
    async findById(id) {
        return this.userRepository.findOne({
            where: { id },
            select: ['id', 'email', 'firstName', 'lastName', 'dateOfBirth', 'height', 'weight', 'gender', 'activityLevel', 'activityLevelMultiplier', 'isActive', 'createdAt', 'updatedAt']
        });
    }
    async update(id, updateUserDto) {
        const user = await this.findById(id);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        Object.assign(user, updateUserDto);
        return this.userRepository.save(user);
    }
    async delete(id) {
        const result = await this.userRepository.delete(id);
        if (result.affected === 0) {
            throw new common_1.NotFoundException('User not found');
        }
    }
    async findAll() {
        return this.userRepository.find({
            select: ['id', 'email', 'firstName', 'lastName', 'isActive', 'createdAt', 'updatedAt']
        });
    }
    toResponseDto(user) {
        return {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            fullName: user.fullName,
            dateOfBirth: user.dateOfBirth,
            height: user.height,
            weight: user.weight,
            bmi: user.bmi,
            activityLevel: user.activityLevel,
            isActive: user.isActive,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
        };
    }
};
exports.UserService = UserService;
exports.UserService = UserService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], UserService);
//# sourceMappingURL=user.service.js.map