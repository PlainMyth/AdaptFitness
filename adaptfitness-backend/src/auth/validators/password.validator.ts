/**
 * Password Validator
 * 
 * Validates password strength to ensure secure user accounts.
 * Enforces minimum security requirements for all passwords.
 * 
 * Password Requirements:
 * - At least 8 characters long
 * - At least one uppercase letter (A-Z)
 * - At least one lowercase letter (a-z)
 * - At least one number (0-9)
 * - At least one special character (!@#$%^&*()_+-=[]{};"\\|,.<>/?)
 */

export class PasswordValidator {
  private static readonly MIN_LENGTH = 8;
  private static readonly REGEX = {
    uppercase: /[A-Z]/,
    lowercase: /[a-z]/,
    number: /[0-9]/,
    special: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/,
  };

  /**
   * Validate password strength
   * 
   * @param password - The password to validate
   * @returns Object with validation result and any error messages
   */
  static validate(password: string): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Check if password exists
    if (!password) {
      errors.push('Password is required');
      return { valid: false, errors };
    }

    // Check minimum length
    if (password.length < this.MIN_LENGTH) {
      errors.push(`Password must be at least ${this.MIN_LENGTH} characters long`);
    }

    // Check for uppercase letter
    if (!this.REGEX.uppercase.test(password)) {
      errors.push('Password must contain at least one uppercase letter (A-Z)');
    }

    // Check for lowercase letter
    if (!this.REGEX.lowercase.test(password)) {
      errors.push('Password must contain at least one lowercase letter (a-z)');
    }

    // Check for number
    if (!this.REGEX.number.test(password)) {
      errors.push('Password must contain at least one number (0-9)');
    }

    // Check for special character
    if (!this.REGEX.special.test(password)) {
      errors.push('Password must contain at least one special character (!@#$%^&*()_+-=[]{};\'"\\|,.<>/?)');
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }

  /**
   * Get password requirements as a formatted string
   * Useful for displaying requirements to users
   */
  static getRequirements(): string[] {
    return [
      `At least ${this.MIN_LENGTH} characters long`,
      'At least one uppercase letter (A-Z)',
      'At least one lowercase letter (a-z)',
      'At least one number (0-9)',
      'At least one special character (!@#$%^&*()_+-=[]{};\'"\\|,.<>/?)',
    ];
  }

  /**
   * Check if password meets minimum requirements (quick check)
   */
  static isValid(password: string): boolean {
    return this.validate(password).valid;
  }
}

