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
exports.GoalCalendarController = void 0;
const common_1 = require("@nestjs/common");
const goal_calendar_service_1 = require("./goal-calendar.service");
const create_goal_calendar_dto_1 = require("./dto/create-goal-calendar.dto");
const update_goal_calendar_dto_1 = require("./dto/update-goal-calendar.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let GoalCalendarController = class GoalCalendarController {
    goalCalendarService;
    constructor(goalCalendarService) {
        this.goalCalendarService = goalCalendarService;
    }
    create(createGoalCalendarDto, req) {
        return this.goalCalendarService.create(createGoalCalendarDto, req.user.id);
    }
    findAll(req) {
        return this.goalCalendarService.findAll(req.user.id);
    }
    findCurrentWeekGoals(req) {
        return this.goalCalendarService.findCurrentWeekGoals(req.user.id);
    }
    getStatistics(req) {
        return this.goalCalendarService.getGoalStatistics(req.user.id);
    }
    getCalendarView(req, year, month) {
        return this.goalCalendarService.getCalendarView(req.user.id, year, month);
    }
    updateProgress(id, req) {
        return this.goalCalendarService.updateGoalProgress(id, req.user.id);
    }
    updateAllProgress(req) {
        return this.goalCalendarService.updateAllGoalProgress(req.user.id);
    }
    findOne(id, req) {
        return this.goalCalendarService.findOne(id, req.user.id);
    }
    update(id, updateGoalCalendarDto, req) {
        return this.goalCalendarService.update(id, updateGoalCalendarDto, req.user.id);
    }
    remove(id, req) {
        return this.goalCalendarService.remove(id, req.user.id);
    }
};
exports.GoalCalendarController = GoalCalendarController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_goal_calendar_dto_1.CreateGoalCalendarDto, Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('current-week'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "findCurrentWeekGoals", null);
__decorate([
    (0, common_1.Get)('statistics'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "getStatistics", null);
__decorate([
    (0, common_1.Get)('calendar-view'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Query)('year', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Query)('month', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Number, Number]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "getCalendarView", null);
__decorate([
    (0, common_1.Post)(':id/update-progress'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "updateProgress", null);
__decorate([
    (0, common_1.Post)('update-all-progress'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "updateAllProgress", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_goal_calendar_dto_1.UpdateGoalCalendarDto, Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], GoalCalendarController.prototype, "remove", null);
exports.GoalCalendarController = GoalCalendarController = __decorate([
    (0, common_1.Controller)('goal-calendar'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [goal_calendar_service_1.GoalCalendarService])
], GoalCalendarController);
//# sourceMappingURL=goal-calendar.controller.js.map