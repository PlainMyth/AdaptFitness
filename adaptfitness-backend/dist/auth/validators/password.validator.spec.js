"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const password_validator_1 = require("./password.validator");
describe('PasswordValidator', () => {
    describe('validate', () => {
        it('should accept a strong password with all requirements', () => {
            const result = password_validator_1.PasswordValidator.validate('SecurePass123!');
            expect(result.valid).toBe(true);
            expect(result.errors).toHaveLength(0);
        });
        it('should reject password that is too short', () => {
            const result = password_validator_1.PasswordValidator.validate('Abc1!');
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password must be at least 8 characters long');
        });
        it('should reject password without uppercase letter', () => {
            const result = password_validator_1.PasswordValidator.validate('securepass123!');
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password must contain at least one uppercase letter (A-Z)');
        });
        it('should reject password without lowercase letter', () => {
            const result = password_validator_1.PasswordValidator.validate('SECUREPASS123!');
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password must contain at least one lowercase letter (a-z)');
        });
        it('should reject password without number', () => {
            const result = password_validator_1.PasswordValidator.validate('SecurePass!');
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password must contain at least one number (0-9)');
        });
        it('should reject password without special character', () => {
            const result = password_validator_1.PasswordValidator.validate('SecurePass123');
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password must contain at least one special character (!@#$%^&*()_+-=[]{};\'"\\|,.<>/?)');
        });
        it('should reject empty password', () => {
            const result = password_validator_1.PasswordValidator.validate('');
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password is required');
        });
        it('should reject null/undefined password', () => {
            const result = password_validator_1.PasswordValidator.validate(null);
            expect(result.valid).toBe(false);
            expect(result.errors).toContain('Password is required');
        });
        it('should return multiple errors for weak password', () => {
            const result = password_validator_1.PasswordValidator.validate('weak');
            expect(result.valid).toBe(false);
            expect(result.errors.length).toBeGreaterThan(1);
            expect(result.errors).toContain('Password must be at least 8 characters long');
            expect(result.errors).toContain('Password must contain at least one uppercase letter (A-Z)');
            expect(result.errors).toContain('Password must contain at least one number (0-9)');
            expect(result.errors).toContain('Password must contain at least one special character (!@#$%^&*()_+-=[]{};\'"\\|,.<>/?)');
        });
        it('should accept password with various special characters', () => {
            const specialChars = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', '{', '}', ';', ':', '"', '<', '>', ',', '.', '/', '?'];
            specialChars.forEach(char => {
                const result = password_validator_1.PasswordValidator.validate(`SecurePass123${char}`);
                expect(result.valid).toBe(true);
            });
        });
        it('should accept minimum valid password (exactly 8 chars)', () => {
            const result = password_validator_1.PasswordValidator.validate('Abcd123!');
            expect(result.valid).toBe(true);
            expect(result.errors).toHaveLength(0);
        });
        it('should accept long strong password', () => {
            const result = password_validator_1.PasswordValidator.validate('ThisIsAVeryLongAndSecurePassword123!@#');
            expect(result.valid).toBe(true);
            expect(result.errors).toHaveLength(0);
        });
    });
    describe('isValid', () => {
        it('should return true for valid password', () => {
            expect(password_validator_1.PasswordValidator.isValid('SecurePass123!')).toBe(true);
        });
        it('should return false for invalid password', () => {
            expect(password_validator_1.PasswordValidator.isValid('weak')).toBe(false);
        });
    });
    describe('getRequirements', () => {
        it('should return array of password requirements', () => {
            const requirements = password_validator_1.PasswordValidator.getRequirements();
            expect(Array.isArray(requirements)).toBe(true);
            expect(requirements.length).toBeGreaterThan(0);
            expect(requirements).toContain('At least 8 characters long');
        });
    });
    describe('Real-world password examples', () => {
        const testCases = [
            { password: 'Password123!', expected: true, description: 'Common strong password' },
            { password: 'MyP@ssw0rd', expected: true, description: 'Password with @' },
            { password: 'Test1234!', expected: true, description: 'Simple but valid' },
            { password: 'password', expected: false, description: 'No uppercase, number, or special' },
            { password: 'PASSWORD', expected: false, description: 'No lowercase, number, or special' },
            { password: '12345678', expected: false, description: 'Only numbers' },
            { password: '!@#$%^&*', expected: false, description: 'Only special chars' },
            { password: 'Passw0rd', expected: false, description: 'Missing special character' },
            { password: 'Pass!', expected: false, description: 'Too short' },
        ];
        testCases.forEach(({ password, expected, description }) => {
            it(`should ${expected ? 'accept' : 'reject'}: ${description}`, () => {
                const result = password_validator_1.PasswordValidator.validate(password);
                expect(result.valid).toBe(expected);
            });
        });
    });
});
//# sourceMappingURL=password.validator.spec.js.map