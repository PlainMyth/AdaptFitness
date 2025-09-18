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
    mealRepository;
    constructor(mealRepository) {
        this.mealRepository = mealRepository;
    }
    async create(mealData) {
        const meal = this.mealRepository.create(mealData);
        return this.mealRepository.save(meal);
    }
    async findAll(userId) {
        return this.mealRepository.find({
            where: { userId },
            order: { mealTime: 'DESC' }
        });
    }
    async findOne(id, userId) {
        const meal = await this.mealRepository.findOne({
            where: { id, userId }
        });
        if (!meal) {
            throw new common_1.NotFoundException('Meal not found');
        }
        return meal;
    }
    async update(id, userId, updateData) {
        const meal = await this.findOne(id, userId);
        Object.assign(meal, updateData);
        return this.mealRepository.save(meal);
    }
    async remove(id, userId) {
        const result = await this.mealRepository.delete({ id, userId });
        if (result.affected === 0) {
            throw new common_1.NotFoundException('Meal not found');
        }
    }
};
exports.MealService = MealService;
exports.MealService = MealService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(meal_entity_1.Meal)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], MealService);
//# sourceMappingURL=meal.service.js.map