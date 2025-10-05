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
    constructor(workoutRepository) {
        this.workoutRepository = workoutRepository;
    }
    validateCreateWorkoutDto(dto) {
        if (!dto.name || dto.name.trim().length === 0) {
            throw new common_1.BadRequestException('Workout name is required.');
        }
        if (!dto.startTime) {
            throw new common_1.BadRequestException('Workout start time is required.');
        }
        if (dto.totalCaloriesBurned !== undefined && dto.totalCaloriesBurned < 0) {
            throw new common_1.BadRequestException('Total calories burned cannot be negative.');
        }
        if (dto.totalDuration !== undefined && dto.totalDuration < 0) {
            throw new common_1.BadRequestException('Total duration cannot be negative.');
        }
        if (!dto.userId || dto.userId.trim().length === 0) {
            throw new common_1.BadRequestException('User ID is required for workout creation.');
        }
    }
    validateUpdateWorkoutDto(dto) {
        if (dto.name !== undefined && dto.name.trim().length === 0) {
            throw new common_1.BadRequestException('Workout name cannot be empty.');
        }
        if (dto.totalCaloriesBurned !== undefined && dto.totalCaloriesBurned < 0) {
            throw new common_1.BadRequestException('Total calories burned cannot be negative.');
        }
        if (dto.totalDuration !== undefined && dto.totalDuration < 0) {
            throw new common_1.BadRequestException('Total duration cannot be negative.');
        }
    }
    async create(createWorkoutDto) {
        this.validateCreateWorkoutDto(createWorkoutDto);
        const workout = this.workoutRepository.create(createWorkoutDto);
        return await this.workoutRepository.save(workout);
    }
    async findAll(userId) {
        return await this.workoutRepository.find({
            where: { user: { id: userId } },
            order: { startTime: 'DESC' },
        });
    }
    async findOne(id) {
        const workout = await this.workoutRepository.findOne({
            where: { id },
            relations: ['user'],
        });
        if (!workout) {
            throw new common_1.NotFoundException(`Workout with ID ${id} not found`);
        }
        return workout;
    }
    async update(id, updateWorkoutDto) {
        this.validateUpdateWorkoutDto(updateWorkoutDto);
        const workout = await this.findOne(id);
        Object.assign(workout, updateWorkoutDto);
        return await this.workoutRepository.save(workout);
    }
    async remove(id) {
        const workout = await this.findOne(id);
        await this.workoutRepository.remove(workout);
    }
    async getCurrentStreakInTimeZone(userId, timeZone) {
        const workouts = await this.workoutRepository.find({
            where: { user: { id: userId } },
            order: { startTime: 'DESC' },
        });
        if (workouts.length === 0) {
            return { streak: 0, lastWorkoutDate: null };
        }
        const timeZoneToUse = timeZone || 'UTC';
        const todayKey = this.getDateKeyInTimeZone(new Date(), timeZoneToUse);
        let streak = 0;
        let currentDateKey = todayKey;
        const hasWorkoutToday = workouts.some(workout => workout.startTime && this.getDateKeyInTimeZone(workout.startTime, timeZoneToUse) === todayKey);
        if (!hasWorkoutToday) {
            currentDateKey = this.getKeyForDaysAgo(1, timeZoneToUse);
        }
        for (let daysAgo = 0; daysAgo < 365; daysAgo++) {
            const dateKey = this.getKeyForDaysAgo(daysAgo, timeZoneToUse);
            const hasWorkoutOnDate = workouts.some(workout => workout.startTime && this.getDateKeyInTimeZone(workout.startTime, timeZoneToUse) === dateKey);
            if (hasWorkoutOnDate) {
                streak++;
            }
            else {
                break;
            }
        }
        const lastWorkout = workouts.find(workout => workout.startTime);
        const lastWorkoutDate = lastWorkout ?
            this.getDateKeyInTimeZone(lastWorkout.startTime, timeZoneToUse) : null;
        return { streak, lastWorkoutDate };
    }
    getDateKeyInTimeZone(date, timeZone) {
        var _a, _b, _c, _d, _e, _f;
        try {
            const formatter = new Intl.DateTimeFormat('en-CA', {
                timeZone: timeZone,
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
            });
            const parts = formatter.formatToParts(date);
            const year = (_b = (_a = parts.find(p => p.type === 'year')) === null || _a === void 0 ? void 0 : _a.value) !== null && _b !== void 0 ? _b : '2025';
            const month = (_d = (_c = parts.find(p => p.type === 'month')) === null || _c === void 0 ? void 0 : _c.value) !== null && _d !== void 0 ? _d : '01';
            const day = (_f = (_e = parts.find(p => p.type === 'day')) === null || _e === void 0 ? void 0 : _e.value) !== null && _f !== void 0 ? _f : '01';
            return `${year}-${month}-${day}`;
        }
        catch (error) {
            const year = date.getUTCFullYear();
            const month = String(date.getUTCMonth() + 1).padStart(2, '0');
            const day = String(date.getUTCDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }
    }
    getKeyForDaysAgo(daysAgo, timeZone) {
        const now = new Date();
        const todayKey = this.getDateKeyInTimeZone(now, timeZone);
        const [y, m, d] = todayKey.split('-').map(Number);
        const base = new Date(y, m - 1, d);
        const stepped = new Date(base.getTime() - daysAgo * 24 * 60 * 60 * 1000);
        return this.getDateKeyInTimeZone(stepped, timeZone);
    }
};
exports.WorkoutService = WorkoutService;
exports.WorkoutService = WorkoutService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(workout_entity_1.Workout)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], WorkoutService);
//# sourceMappingURL=workout.service.js.map