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
Object.defineProperty(exports, "__esModule", { value: true });
exports.GoalCalendar = void 0;
const typeorm_1 = require("typeorm");
const user_entity_1 = require("../user/user.entity");
let GoalCalendar = class GoalCalendar {
    get weekIdentifier() {
        const year = this.weekStartDate.getFullYear();
        const weekNumber = this.getWeekNumber(this.weekStartDate);
        return `${year}-W${weekNumber.toString().padStart(2, '0')}`;
    }
    getWeekNumber(date) {
        const start = new Date(date.getFullYear(), 0, 1);
        const diff = date.getTime() - start.getTime();
        const oneWeek = 1000 * 60 * 60 * 24 * 7;
        return Math.floor(diff / oneWeek) + 1;
    }
    get status() {
        if (this.isCompleted)
            return 'completed';
        if (this.completionPercentage >= 100)
            return 'achieved';
        if (this.completionPercentage >= 75)
            return 'on_track';
        if (this.completionPercentage >= 50)
            return 'moderate_progress';
        if (this.completionPercentage > 0)
            return 'started';
        return 'not_started';
    }
    get daysRemaining() {
        const today = new Date();
        const endDate = new Date(this.weekEndDate);
        endDate.setHours(23, 59, 59, 999);
        if (today > endDate)
            return 0;
        const diffTime = endDate.getTime() - today.getTime();
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }
    get isCurrentWeek() {
        const today = new Date();
        const start = new Date(this.weekStartDate);
        const end = new Date(this.weekEndDate);
        return today >= start && today <= end;
    }
    get unit() {
        switch (this.goalType) {
            case 'workouts_count': return 'workouts';
            case 'total_duration': return 'minutes';
            case 'total_calories': return 'calories';
            case 'total_sets': return 'sets';
            case 'total_reps': return 'reps';
            case 'total_weight': return 'kg';
            case 'streak_days': return 'days';
            default: return 'units';
        }
    }
};
exports.GoalCalendar = GoalCalendar;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], GoalCalendar.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], GoalCalendar.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'userId' }),
    __metadata("design:type", user_entity_1.User)
], GoalCalendar.prototype, "user", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date' }),
    __metadata("design:type", Date)
], GoalCalendar.prototype, "weekStartDate", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date' }),
    __metadata("design:type", Date)
], GoalCalendar.prototype, "weekEndDate", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: ['workouts_count', 'total_duration', 'total_calories', 'total_sets', 'total_reps', 'total_weight', 'streak_days']
    }),
    __metadata("design:type", String)
], GoalCalendar.prototype, "goalType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'decimal', precision: 10, scale: 2 }),
    __metadata("design:type", Number)
], GoalCalendar.prototype, "targetValue", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'decimal', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], GoalCalendar.prototype, "currentValue", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'decimal', precision: 5, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], GoalCalendar.prototype, "completionPercentage", void 0);
__decorate([
    (0, typeorm_1.Column)({ default: false }),
    __metadata("design:type", Boolean)
], GoalCalendar.prototype, "isCompleted", void 0);
__decorate([
    (0, typeorm_1.Column)({ default: false }),
    __metadata("design:type", Boolean)
], GoalCalendar.prototype, "isActive", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], GoalCalendar.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({
        nullable: true,
        type: 'enum',
        enum: ['strength', 'cardio', 'flexibility', 'sports', 'other']
    }),
    __metadata("design:type", String)
], GoalCalendar.prototype, "workoutType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'json', nullable: true }),
    __metadata("design:type", Array)
], GoalCalendar.prototype, "progressHistory", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], GoalCalendar.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], GoalCalendar.prototype, "updatedAt", void 0);
exports.GoalCalendar = GoalCalendar = __decorate([
    (0, typeorm_1.Entity)('goal_calendars')
], GoalCalendar);
//# sourceMappingURL=goal-calendar.entity.js.map