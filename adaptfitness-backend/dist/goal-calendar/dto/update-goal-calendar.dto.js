"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateGoalCalendarDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_goal_calendar_dto_1 = require("./create-goal-calendar.dto");
class UpdateGoalCalendarDto extends (0, mapped_types_1.PartialType)(create_goal_calendar_dto_1.CreateGoalCalendarDto) {
}
exports.UpdateGoalCalendarDto = UpdateGoalCalendarDto;
//# sourceMappingURL=update-goal-calendar.dto.js.map