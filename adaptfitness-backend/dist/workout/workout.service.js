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
    async getCurrentStreak(userId) {
        return this.getCurrentStreakInTimeZone(userId);
    }
    async getCurrentStreakInTimeZone(userId, timeZone) {
        const tz = this.validateTimeZone(timeZone);
        const workouts = await this.workoutRepository.find({
            where: { userId },
            select: ['startTime'],
            order: { startTime: 'DESC' },
        });
        if (!workouts.length) {
            return { streak: 0 };
        }
        const dateSet = new Set();
        for (const w of workouts) {
            if (!w.startTime)
                continue;
            dateSet.add(this.getDateKeyInTimeZone(w.startTime, tz));
        }
        if (dateSet.size === 0) {
            return { streak: 0 };
        }
        const todayKey = this.getKeyForDaysAgo(0, tz);
        const yKey = this.getKeyForDaysAgo(1, tz);
        let daysAgo = 0;
        let streak = 0;
        if (dateSet.has(todayKey)) {
            streak = 1;
        }
        else if (dateSet.has(yKey)) {
            daysAgo = 1;
            streak = 1;
        }
        else {
            return { streak: 0 };
        }
        while (true) {
            const nextKey = this.getKeyForDaysAgo(daysAgo + 1, tz);
            if (dateSet.has(nextKey)) {
                streak += 1;
                daysAgo += 1;
            }
            else {
                break;
            }
        }
        const lastWorkoutDate = [...dateSet].sort().pop();
        return { streak, lastWorkoutDate };
    }
    validateTimeZone(tz) {
        if (!tz)
            return 'UTC';
        try {
            new Intl.DateTimeFormat('en-US', { timeZone: tz }).format(new Date());
            return tz;
        }
        catch {
            return 'UTC';
        }
    }
    getDateKeyInTimeZone(date, timeZone) {
        const fmt = new Intl.DateTimeFormat('en-CA', {
            timeZone,
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
        });
        const parts = fmt.formatToParts(date);
        const year = parts.find(p => p.type === 'year')?.value ?? '0000';
        const month = parts.find(p => p.type === 'month')?.value ?? '01';
        const day = parts.find(p => p.type === 'day')?.value ?? '01';
        return `${year}-${month}-${day}`;
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