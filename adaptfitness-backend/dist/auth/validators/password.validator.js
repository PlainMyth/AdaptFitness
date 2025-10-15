"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PasswordValidator = void 0;
class PasswordValidator {
    static validate(password) {
        const errors = [];
        if (!password) {
            errors.push('Password is required');
            return { valid: false, errors };
        }
        if (password.length < this.MIN_LENGTH) {
            errors.push(`Password must be at least ${this.MIN_LENGTH} characters long`);
        }
        if (!this.REGEX.uppercase.test(password)) {
            errors.push('Password must contain at least one uppercase letter (A-Z)');
        }
        if (!this.REGEX.lowercase.test(password)) {
            errors.push('Password must contain at least one lowercase letter (a-z)');
        }
        if (!this.REGEX.number.test(password)) {
            errors.push('Password must contain at least one number (0-9)');
        }
        if (!this.REGEX.special.test(password)) {
            errors.push('Password must contain at least one special character (!@#$%^&*()_+-=[]{};\'"\\|,.<>/?)');
        }
        return {
            valid: errors.length === 0,
            errors,
        };
    }
    static getRequirements() {
        return [
            `At least ${this.MIN_LENGTH} characters long`,
            'At least one uppercase letter (A-Z)',
            'At least one lowercase letter (a-z)',
            'At least one number (0-9)',
            'At least one special character (!@#$%^&*()_+-=[]{};\'"\\|,.<>/?)',
        ];
    }
    static isValid(password) {
        return this.validate(password).valid;
    }
}
exports.PasswordValidator = PasswordValidator;
PasswordValidator.MIN_LENGTH = 8;
PasswordValidator.REGEX = {
    uppercase: /[A-Z]/,
    lowercase: /[a-z]/,
    number: /[0-9]/,
    special: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/,
};
//# sourceMappingURL=password.validator.js.map