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
exports.HealthMetricsController = void 0;
const common_1 = require("@nestjs/common");
const health_metrics_service_1 = require("./health-metrics.service");
const create_health_metrics_dto_1 = require("./dto/create-health-metrics.dto");
const update_health_metrics_dto_1 = require("./dto/update-health-metrics.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let HealthMetricsController = class HealthMetricsController {
    constructor(healthMetricsService) {
        this.healthMetricsService = healthMetricsService;
    }
    create(createHealthMetricsDto, req) {
        return this.healthMetricsService.create(createHealthMetricsDto, req.user.id);
    }
    findAll(req) {
        return this.healthMetricsService.findAll(req.user.id);
    }
    findLatest(req) {
        return this.healthMetricsService.findLatest(req.user.id);
    }
    getCalculatedMetrics(req) {
        return this.healthMetricsService.getCalculatedMetrics(req.user.id);
    }
    findOne(id, req) {
        return this.healthMetricsService.findOne(id, req.user.id);
    }
    update(id, updateHealthMetricsDto, req) {
        return this.healthMetricsService.update(id, updateHealthMetricsDto, req.user.id);
    }
    remove(id, req) {
        return this.healthMetricsService.remove(id, req.user.id);
    }
};
exports.HealthMetricsController = HealthMetricsController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_health_metrics_dto_1.CreateHealthMetricsDto, Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('latest'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "findLatest", null);
__decorate([
    (0, common_1.Get)('calculations'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "getCalculatedMetrics", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_health_metrics_dto_1.UpdateHealthMetricsDto, Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], HealthMetricsController.prototype, "remove", null);
exports.HealthMetricsController = HealthMetricsController = __decorate([
    (0, common_1.Controller)('health-metrics'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [health_metrics_service_1.HealthMetricsService])
], HealthMetricsController);
//# sourceMappingURL=health-metrics.controller.js.map