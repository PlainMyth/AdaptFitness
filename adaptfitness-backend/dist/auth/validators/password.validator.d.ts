export declare class PasswordValidator {
    private static readonly MIN_LENGTH;
    private static readonly REGEX;
    static validate(password: string): {
        valid: boolean;
        errors: string[];
    };
    static getRequirements(): string[];
    static isValid(password: string): boolean;
}
