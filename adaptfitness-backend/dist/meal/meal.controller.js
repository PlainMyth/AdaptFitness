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
exports.MealController = void 0;
const common_1 = require("@nestjs/common");
const meal_service_1 = require("./meal.service");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let MealController = class MealController {
    mealService;
    constructor(mealService) {
        this.mealService = mealService;
    }
    async create(req, mealData) {
        return this.mealService.create({
            ...mealData,
            userId: req.user.id
        });
    }
    async findAll(req) {
        return this.mealService.findAll(req.user.id);
    }
    async getCurrentStreak(req, tz) {
        return this.mealService.getCurrentStreakInTimeZone(req.user.id, tz);
    }
    async findOne(req, id) {
        return this.mealService.findOne(id, req.user.id);
    }
    async update(req, id, updateData) {
        return this.mealService.update(id, req.user.id, updateData);
    }
    async remove(req, id) {
        await this.mealService.remove(id, req.user.id);
        return { message: 'Meal deleted successfully' };
    }
};
exports.MealController = MealController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], MealController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], MealController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('streak/current'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Query)('tz')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], MealController.prototype, "getCurrentStreak", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], MealController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], MealController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], MealController.prototype, "remove", null);
exports.MealController = MealController = __decorate([
    (0, common_1.Controller)('meals'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [meal_service_1.MealService])
], MealController);
//# sourceMappingURL=meal.controller.js.map