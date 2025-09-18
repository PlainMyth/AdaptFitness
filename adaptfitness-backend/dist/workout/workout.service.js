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
exports.WorkoutService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const workout_entity_1 = require("./workout.entity");
let WorkoutService = class WorkoutService {
    workoutRepository;
    constructor(workoutRepository) {
        this.workoutRepository = workoutRepository;
    }
    async create(workoutData) {
        const workout = this.workoutRepository.create(workoutData);
        return this.workoutRepository.save(workout);
    }
    async findAll(userId) {
        return this.workoutRepository.find({
            where: { userId },
            order: { startTime: 'DESC' }
        });
    }
    async findOne(id, userId) {
        const workout = await this.workoutRepository.findOne({
            where: { id, userId }
        });
        if (!workout) {
            throw new common_1.NotFoundException('Workout not found');
        }
        return workout;
    }
    async update(id, userId, updateData) {
        const workout = await this.findOne(id, userId);
        Object.assign(workout, updateData);
        return this.workoutRepository.save(workout);
    }
    async remove(id, userId) {
        const result = await this.workoutRepository.delete({ id, userId });
        if (result.affected === 0) {
            throw new common_1.NotFoundException('Workout not found');
        }
    }
};
exports.WorkoutService = WorkoutService;
exports.WorkoutService = WorkoutService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(workout_entity_1.Workout)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], WorkoutService);
//# sourceMappingURL=workout.service.js.map