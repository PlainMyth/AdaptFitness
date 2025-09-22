"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
if (typeof Date.UTC === 'undefined') {
    Date.UTC = function (year, month, day, hour = 0, minute = 0, second = 0, millisecond = 0) {
        return new Date(year, month, day, hour, minute, second, millisecond).getTime();
    };
}
if (typeof Intl === 'undefined') {
    global.Intl = {
        DateTimeFormat: function (locale, options) {
            return {
                format: (date) => {
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0');
                    const day = String(date.getDate()).padStart(2, '0');
                    return `${year}-${month}-${day}`;
                }
            };
        }
    };
}
//# sourceMappingURL=test-setup.js.map