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
exports.HealthMetricsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const health_metrics_entity_1 = require("./health-metrics.entity");
const user_entity_1 = require("../user/user.entity");
let HealthMetricsService = class HealthMetricsService {
    constructor(healthMetricsRepository, userRepository) {
        this.healthMetricsRepository = healthMetricsRepository;
        this.userRepository = userRepository;
    }
    async create(createHealthMetricsDto, userId) {
        const healthMetrics = this.healthMetricsRepository.create({
            ...createHealthMetricsDto,
            userId,
        });
        const calculatedMetrics = await this.calculateAllMetrics(healthMetrics, userId);
        return this.healthMetricsRepository.save(calculatedMetrics);
    }
    async findAll(userId) {
        return this.healthMetricsRepository.find({
            where: { userId },
            order: { createdAt: 'DESC' },
        });
    }
    async findOne(id, userId) {
        const healthMetrics = await this.healthMetricsRepository.findOne({
            where: { id, userId },
        });
        if (!healthMetrics) {
            throw new common_1.NotFoundException('Health metrics not found');
        }
        return healthMetrics;
    }
    async findLatest(userId) {
        const healthMetrics = await this.healthMetricsRepository.findOne({
            where: { userId },
            order: { createdAt: 'DESC' },
        });
        if (!healthMetrics) {
            throw new common_1.NotFoundException('No health metrics found');
        }
        return healthMetrics;
    }
    async update(id, updateHealthMetricsDto, userId) {
        const healthMetrics = await this.findOne(id, userId);
        Object.assign(healthMetrics, updateHealthMetricsDto);
        const calculatedMetrics = await this.calculateAllMetrics(healthMetrics, userId);
        return this.healthMetricsRepository.save(calculatedMetrics);
    }
    async remove(id, userId) {
        const healthMetrics = await this.findOne(id, userId);
        await this.healthMetricsRepository.remove(healthMetrics);
    }
    async calculateAllMetrics(healthMetrics, userId) {
        const user = await this.getUserData(userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        healthMetrics.bmi = this.calculateBMI(healthMetrics.currentWeight, user.height);
        if (healthMetrics.bodyFatPercentage) {
            healthMetrics.leanBodyMass = this.calculateLeanBodyMass(healthMetrics.currentWeight, healthMetrics.bodyFatPercentage);
            healthMetrics.skeletalMuscleMass = this.calculateSkeletalMuscleMass(healthMetrics.currentWeight, user.height, user.gender);
        }
        if (healthMetrics.waistCircumference && healthMetrics.hipCircumference) {
            healthMetrics.waistToHipRatio = this.calculateWaistToHipRatio(healthMetrics.waistCircumference, healthMetrics.hipCircumference);
        }
        if (healthMetrics.waistCircumference && user.height) {
            healthMetrics.waistToHeightRatio = this.calculateWaistToHeightRatio(healthMetrics.waistCircumference, user.height);
        }
        if (healthMetrics.waistCircumference) {
            healthMetrics.absi = this.calculateABSI(healthMetrics.currentWeight, user.height, healthMetrics.waistCircumference);
        }
        healthMetrics.rmr = this.calculateRMR(healthMetrics.currentWeight, user.height, user.age, user.gender);
        healthMetrics.physicalActivityLevel = user.activityLevel || 1.4;
        healthMetrics.tdee = this.calculateTDEE(healthMetrics.rmr, healthMetrics.physicalActivityLevel);
        if (healthMetrics.bodyFatPercentage) {
            healthMetrics.maximumFatLoss = this.calculateMaximumFatLoss(healthMetrics.currentWeight, healthMetrics.bodyFatPercentage);
        }
        if (healthMetrics.goalWeight) {
            healthMetrics.calorieDeficit = this.calculateCalorieDeficit(healthMetrics.tdee, healthMetrics.currentWeight, healthMetrics.goalWeight);
        }
        return healthMetrics;
    }
    calculateBMI(weight, height) {
        const heightInMeters = height / 100;
        return Number((weight / (heightInMeters * heightInMeters)).toFixed(2));
    }
    calculateLeanBodyMass(weight, bodyFatPercentage) {
        return Number((weight * (1 - bodyFatPercentage / 100)).toFixed(2));
    }
    calculateSkeletalMuscleMass(weight, height, gender) {
        if (gender === 'male') {
            return Number((0.407 * weight + 0.267 * height - 19.2).toFixed(2));
        }
        else {
            return Number((0.252 * weight + 0.473 * height - 48.3).toFixed(2));
        }
    }
    calculateWaistToHipRatio(waist, hip) {
        return Number((waist / hip).toFixed(3));
    }
    calculateWaistToHeightRatio(waist, height) {
        return Number((waist / height).toFixed(3));
    }
    calculateABSI(weight, height, waist) {
        const heightInMeters = height / 100;
        const weightInKg = weight;
        const waistInMeters = waist / 100;
        return Number((waistInMeters / (Math.pow(weightInKg, 2 / 3) * Math.pow(heightInMeters, 1 / 2))).toFixed(3));
    }
    calculateRMR(weight, height, age, gender) {
        if (gender === 'male') {
            return Number((10 * weight + 6.25 * height - 5 * age + 5).toFixed(2));
        }
        else {
            return Number((10 * weight + 6.25 * height - 5 * age - 161).toFixed(2));
        }
    }
    calculateTDEE(rmr, activityLevel) {
        return Number((rmr * activityLevel).toFixed(2));
    }
    calculateMaximumFatLoss(weight, bodyFatPercentage) {
        const maxLossPerWeek = weight * 0.01;
        return Number(maxLossPerWeek.toFixed(2));
    }
    calculateCalorieDeficit(tdee, currentWeight, goalWeight) {
        const weightDifference = currentWeight - goalWeight;
        if (weightDifference <= 0)
            return 0;
        const weeklyDeficit = weightDifference * 3500;
        const dailyDeficit = weeklyDeficit / 7;
        return Number(dailyDeficit.toFixed(2));
    }
    async getUserData(userId) {
        const user = await this.userRepository.findOne({
            where: { id: userId },
        });
        if (!user)
            return null;
        return {
            height: user.height || 175,
            age: user.age || 25,
            gender: user.gender || 'male',
            activityLevel: user.activityLevelMultiplier || 1.4
        };
    }
    async getCalculatedMetrics(userId) {
        var _a;
        const latest = await this.findLatest(userId);
        return {
            bmi: latest.bmi,
            tdee: latest.tdee,
            rmr: latest.rmr,
            bodyFatCategory: this.getBodyFatCategory(latest.bodyFatPercentage, ((_a = latest.user) === null || _a === void 0 ? void 0 : _a.gender) || 'male'),
            bmiCategory: this.getBMICategory(latest.bmi),
        };
    }
    getBodyFatCategory(bodyFatPercentage, gender) {
        if (!bodyFatPercentage)
            return 'Unknown';
        if (gender === 'male') {
            if (bodyFatPercentage < 6)
                return 'Essential Fat';
            if (bodyFatPercentage < 14)
                return 'Athletes';
            if (bodyFatPercentage < 18)
                return 'Fitness';
            if (bodyFatPercentage < 25)
                return 'Average';
            return 'Obese';
        }
        else {
            if (bodyFatPercentage < 10)
                return 'Essential Fat';
            if (bodyFatPercentage < 16)
                return 'Athletes';
            if (bodyFatPercentage < 20)
                return 'Fitness';
            if (bodyFatPercentage < 32)
                return 'Average';
            return 'Obese';
        }
    }
    getBMICategory(bmi) {
        if (bmi < 18.5)
            return 'Underweight';
        if (bmi < 25)
            return 'Normal weight';
        if (bmi < 30)
            return 'Overweight';
        return 'Obese';
    }
};
exports.HealthMetricsService = HealthMetricsService;
exports.HealthMetricsService = HealthMetricsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(health_metrics_entity_1.HealthMetrics)),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], HealthMetricsService);
//# sourceMappingURL=health-metrics.service.js.map