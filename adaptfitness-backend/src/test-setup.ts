/**
 * Test Setup
 *
 * This file sets up the test environment for Jest tests. It ensures that all necessary dependencies and configurations are available during testing.
 *
 * Key responsibilities:
 * - Import necessary test dependencies
 * - Configure test environment
 * - Set up global test utilities
 * - Ensure proper test isolation
 * - Provide polyfills for missing functions
 */

import 'reflect-metadata';

// Polyfill Date.UTC for Jest test environment
if (typeof Date.UTC === 'undefined') {
  Date.UTC = function(year: number, month: number, day: number, hour: number = 0, minute: number = 0, second: number = 0, millisecond: number = 0): number {
    return new Date(year, month, day, hour, minute, second, millisecond).getTime();
  };
}

// Additional polyfills for comprehensive testing
if (typeof Intl === 'undefined') {
  // Mock Intl for timezone support in tests
  (global as any).Intl = {
    DateTimeFormat: function(locale: string, options: any) {
      return {
        format: (date: Date) => {
          const year = date.getFullYear();
          const month = String(date.getMonth() + 1).padStart(2, '0');
          const day = String(date.getDate()).padStart(2, '0');
          return `${year}-${month}-${day}`;
        }
      };
    }
  };
}