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
exports.MealService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const meal_entity_1 = require("./meal.entity");
let MealService = class MealService {
    constructor(mealRepository) {
        this.mealRepository = mealRepository;
    }
    async create(createMealDto) {
        this.validateCreateMealDto(createMealDto);
        const meal = this.mealRepository.create(createMealDto);
        return await this.mealRepository.save(meal);
    }
    async findAll(userId) {
        return await this.mealRepository.find({
            where: { user: { id: userId } },
            order: { mealTime: 'DESC' },
        });
    }
    async findOne(id) {
        const meal = await this.mealRepository.findOne({
            where: { id },
            relations: ['user'],
        });
        if (!meal) {
            throw new common_1.NotFoundException(`Meal with ID ${id} not found`);
        }
        return meal;
    }
    async update(id, updateMealDto) {
        this.validateUpdateMealDto(updateMealDto);
        const meal = await this.findOne(id);
        Object.assign(meal, updateMealDto);
        return await this.mealRepository.save(meal);
    }
    async remove(id) {
        const meal = await this.findOne(id);
        await this.mealRepository.remove(meal);
    }
    async getCurrentStreakInTimeZone(userId, timeZone) {
        const meals = await this.mealRepository.find({
            where: { user: { id: userId } },
            order: { mealTime: 'DESC' },
        });
        if (meals.length === 0) {
            return { streak: 0, lastMealDate: null };
        }
        const timeZoneToUse = timeZone || 'UTC';
        const todayKey = this.getDateKeyInTimeZone(new Date(), timeZoneToUse);
        let streak = 0;
        let currentDateKey = todayKey;
        const hasMealToday = meals.some(meal => meal.mealTime && this.getDateKeyInTimeZone(meal.mealTime, timeZoneToUse) === todayKey);
        if (!hasMealToday) {
            currentDateKey = this.getKeyForDaysAgo(1, timeZoneToUse);
        }
        for (let daysAgo = 0; daysAgo < 365; daysAgo++) {
            const dateKey = this.getKeyForDaysAgo(daysAgo, timeZoneToUse);
            const hasMealOnDate = meals.some(meal => meal.mealTime && this.getDateKeyInTimeZone(meal.mealTime, timeZoneToUse) === dateKey);
            if (hasMealOnDate) {
                streak++;
            }
            else {
                break;
            }
        }
        const lastMeal = meals.find(meal => meal.mealTime);
        const lastMealDate = lastMeal ?
            this.getDateKeyInTimeZone(lastMeal.mealTime, timeZoneToUse) : null;
        return { streak, lastMealDate };
    }
    validateCreateMealDto(dto) {
        if (!dto.name || dto.name.trim().length === 0) {
            throw new common_1.BadRequestException('Meal name is required and cannot be empty');
        }
        if (!dto.description || dto.description.trim().length === 0) {
            throw new common_1.BadRequestException('Meal description is required and cannot be empty');
        }
        if (!dto.mealTime) {
            throw new common_1.BadRequestException('Meal time is required');
        }
        if (!dto.userId || dto.userId.trim().length === 0) {
            throw new common_1.BadRequestException('User ID is required');
        }
        if (dto.totalCalories !== undefined && dto.totalCalories < 0) {
            throw new common_1.BadRequestException('Total calories cannot be negative');
        }
        const mealTime = new Date(dto.mealTime);
        if (isNaN(mealTime.getTime())) {
            throw new common_1.BadRequestException('Invalid meal time format');
        }
    }
    validateUpdateMealDto(dto) {
        if (dto.name !== undefined && (!dto.name || dto.name.trim().length === 0)) {
            throw new common_1.BadRequestException('Meal name cannot be empty');
        }
        if (dto.description !== undefined && (!dto.description || dto.description.trim().length === 0)) {
            throw new common_1.BadRequestException('Meal description cannot be empty');
        }
        if (dto.mealTime !== undefined) {
            const mealTime = new Date(dto.mealTime);
            if (isNaN(mealTime.getTime())) {
                throw new common_1.BadRequestException('Invalid meal time format');
            }
        }
        if (dto.totalCalories !== undefined && dto.totalCalories < 0) {
            throw new common_1.BadRequestException('Total calories cannot be negative');
        }
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
exports.MealService = MealService;
exports.MealService = MealService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(meal_entity_1.Meal)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], MealService);
//# sourceMappingURL=meal.service.js.map