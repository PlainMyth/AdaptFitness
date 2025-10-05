// Global setup for Jest tests
// This file runs before all tests to set up the environment

module.exports = async () => {
  // Polyfill Date.UTC for Jest test environment
  if (typeof Date.UTC === 'undefined') {
    Date.UTC = function(year, month, day, hour = 0, minute = 0, second = 0, millisecond = 0) {
      return new Date(year, month, day, hour, minute, second, millisecond).getTime();
    };
  }

  // Additional polyfills for comprehensive testing
  if (typeof Intl === 'undefined') {
    // Mock Intl for timezone support in tests
    global.Intl = {
      DateTimeFormat: function(locale, options) {
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

  console.log('Jest global setup completed - Date.UTC polyfill loaded');
};