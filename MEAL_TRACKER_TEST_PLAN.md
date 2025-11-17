# Meal Tracker Test Plan

This document outlines comprehensive test cases for verifying the meal tracker functionality in both backend and frontend.

## 📋 Test Coverage Overview

### Backend Tests
- ✅ Unit Tests (`meal.service.spec.ts`) - Service layer logic
- ✅ Integration Tests (`meal.controller.spec.ts`) - Controller endpoints
- ✅ E2E Tests (`meal.e2e-spec.ts`) - Full HTTP request/response flow
- ✅ API Test Script (`test-meal-tracker.sh`) - Manual testing script

### Frontend Tests
- ✅ Unit Tests (`MealViewModelTests.swift`) - ViewModel logic
- ✅ UI Tests (`MealTrackerUITests.swift`) - User interface interactions

---

## 🧪 Backend Test Execution

### Run All Backend Tests

```bash
cd adaptfitness-backend

# Run all tests
npm test

# Run only meal-related tests
npm test -- --testPathPattern=meal

# Run with coverage
npm run test:cov -- --testPathPattern=meal
```

### Run Specific Test Suites

```bash
# Unit tests (service layer)
npm test -- meal.service.spec.ts

# Integration tests (controller)
npm test -- meal.controller.spec.ts

# E2E tests (full HTTP flow)
npm test -- meal.e2e-spec.ts
```

### Run Manual API Test Script

```bash
cd adaptfitness-backend

# Test against local server (default)
./test-meal-tracker.sh

# Test against production
./test-meal-tracker.sh https://adaptfitness-production.up.railway.app
```

**Prerequisites:**
- Backend server must be running
- PostgreSQL database must be accessible
- `curl` and `jq` must be installed (optional, for JSON parsing)

---

## 📱 Frontend Test Execution

### Run iOS Unit Tests

1. Open the project in Xcode:
   ```bash
   open adaptfitness-ios/AdaptFitness.xcodeproj
   ```

2. Select the test target:
   - Product → Test (⌘U)
   - Or use the test navigator (⌘6) and click the play button

3. Run specific test:
   - Click the diamond icon next to the test function
   - Or right-click → Run

### Run iOS UI Tests

1. Select the `AdaptFitnessUITests` scheme
2. Product → Test (⌘U)
3. Or use the test navigator to run individual UI tests

### Run Tests from Command Line

```bash
cd adaptfitness-ios

# Run all tests
xcodebuild test \
  -scheme AdaptFitness \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

# Run specific test suite
xcodebuild test \
  -scheme AdaptFitness \
  -only-testing:AdaptFitnessTests/MealViewModelTests \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

---

## ✅ Test Cases Checklist

### Backend - CRUD Operations

- [x] **Create Meal**
  - ✅ Create meal with all required fields
  - ✅ Create meal with optional fields
  - ✅ Reject meal creation without authentication
  - ✅ Validate required fields
  - ✅ Set userId from authenticated user

- [x] **Read Meals**
  - ✅ Get all meals for authenticated user
  - ✅ Get single meal by ID
  - ✅ Return empty array for user with no meals
  - ✅ Reject requests without authentication
  - ✅ Return 404 for non-existent meal

- [x] **Update Meal**
  - ✅ Update meal successfully
  - ✅ Update partial meal data
  - ✅ Reject updates without authentication

- [x] **Delete Meal**
  - ✅ Delete meal successfully
  - ✅ Verify meal is deleted
  - ✅ Reject deletion without authentication

### Backend - Food Search

- [x] **Food Search**
  - ✅ Search for foods successfully
  - ✅ Handle empty search results
  - ✅ Require authentication
  - ✅ Validate query parameters

- [x] **Barcode Lookup**
  - ✅ Get food by barcode successfully
  - ✅ Handle barcode not found
  - ✅ Require authentication

### Backend - Streak Tracking

- [x] **Streak Calculation**
  - ✅ Return current streak
  - ✅ Handle timezone parameter
  - ✅ Calculate streak with consecutive meals
  - ✅ Handle multiple meals on same day
  - ✅ Return zero streak when no meals exist

### Frontend - ViewModel Tests

- [x] **Initialization**
  - ✅ ViewModel initializes with empty meals
  - ✅ Loading state is false initially

- [x] **Meal Management**
  - ✅ Add single meal
  - ✅ Add multiple meals
  - ✅ Delete meals

- [x] **Computed Properties**
  - ✅ Group meals by type
  - ✅ Calculate total calories today
  - ✅ Calculate total protein today
  - ✅ Filter today's meals
  - ✅ Handle empty meals list

### Frontend - UI Tests

- [x] **Navigation**
  - ✅ Meals tab exists
  - ✅ Navigate to meal tracker
  - ✅ Meal tracker screen displays

- [x] **Meal List**
  - ✅ Display empty state
  - ✅ Display meals when available

- [x] **Add Meal**
  - ✅ Add meal button exists
  - ✅ Add meal flow works

- [x] **Food Search**
  - ✅ Search functionality works
  - ✅ Search results display

- [x] **Error Handling**
  - ✅ App remains responsive on network errors
  - ✅ Error messages display appropriately

---

## 🐛 Troubleshooting

### Backend Tests Fail

**Issue:** Database connection errors
```bash
# Ensure PostgreSQL is running
pg_isready

# Check environment variables
cat adaptfitness-backend/.env
```

**Issue:** Port already in use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

### Frontend Tests Fail

**Issue:** Simulator not available
```bash
# List available simulators
xcrun simctl list devices

# Boot a simulator
xcrun simctl boot "iPhone 15"
```

**Issue:** Test target not found
- Ensure test files are added to the test target in Xcode
- Check Build Phases → Compile Sources

---

## 📊 Test Results Interpretation

### Backend Test Output

```
PASS  src/meal/meal.service.spec.ts
PASS  src/meal/meal.controller.spec.ts
PASS  src/meal/meal.e2e-spec.ts

Test Suites: 3 passed, 3 total
Tests:       45 passed, 45 total
```

### Frontend Test Output

In Xcode Test Navigator:
- ✅ Green checkmark = Test passed
- ❌ Red X = Test failed
- ⚠️ Yellow warning = Test has warnings

---

## 🔄 Continuous Integration

### GitHub Actions Example

```yaml
name: Meal Tracker Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: cd adaptfitness-backend && npm install
      - run: cd adaptfitness-backend && npm test -- --testPathPattern=meal

  frontend-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - run: cd adaptfitness-ios && xcodebuild test -scheme AdaptFitness
```

---

## 📝 Adding New Tests

### Backend Test Template

```typescript
describe('New Feature', () => {
  it('should do something', async () => {
    // Arrange
    const testData = { ... };
    
    // Act
    const result = await service.method(testData);
    
    // Assert
    expect(result).toBeDefined();
  });
});
```

### Frontend Test Template

```swift
@Test func testNewFeature() async throws {
    let viewModel = MealViewModel()
    
    // Test implementation
    #expect(viewModel.someProperty == expectedValue)
}
```

---

## 🎯 Success Criteria

All tests should pass with:
- ✅ 100% of critical paths covered
- ✅ All edge cases handled
- ✅ Error scenarios tested
- ✅ Authentication verified
- ✅ Data validation confirmed

---

## 📚 Additional Resources

- [NestJS Testing Documentation](https://docs.nestjs.com/fundamentals/testing)
- [XCTest Framework Guide](https://developer.apple.com/documentation/xctest)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)

