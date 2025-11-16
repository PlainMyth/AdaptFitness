# Test Plan - Health Metrics Frontend Feature
 
**Sprint:** Sprint 3  
**Feature:** Health Metrics Display and Management on iOS Frontend  
**Build Target:** iOS 17+

---

## Executive Summary

This test plan covers comprehensive testing of the Health Metrics feature on the iOS frontend. The feature allows users to view and input health metrics data, with all calculations performed by the backend API. Testing focuses on functionality, API integration, data validation, UI/UX, and error handling.

---

## Test Categories

### A. Functional Testing (iOS Frontend)

**Rationale:** Verify that health metrics display correctly from backend API calculations and that user interactions work as expected.

**Methodology:** Manual testing with iOS Simulator and real device testing

**Justification:** 
- UI rendering requires visual verification
- Touch interactions need real device testing
- iOS Simulator provides consistent testing environment
- Real device testing catches hardware-specific issues (camera, sensors if used)

**Test Environment:**
- iOS Simulator (iPhone 15 Pro, iOS 17+)
- Real iPhone device (if available)
- Backend API running on production (https://adaptfitness-production.up.railway.app)

**Test Scope:**
- Health Metrics view displays all calculated values
- Add Health Metrics form accepts input and submits correctly
- Calculations displayed match backend responses
- Navigation between tabs works correctly
- Empty states display when no data exists
- Loading states appear during API calls

---

### B. API Integration Testing

**Rationale:** Ensure iOS app correctly calls health metrics endpoints and handles responses properly.

**Methodology:** E2E tests using Supertest + manual API verification with Postman/curl

**Justification:**
- Verify complete data flow from iOS → Backend → Database → Backend → iOS
- Ensure authentication tokens are properly included
- Verify request/response formats match expected DTOs
- Test error responses are handled correctly

**Test Scope:**
- GET /health-metrics/latest returns correct data structure
- GET /health-metrics/calculations returns simplified response
- POST /health-metrics creates entry and returns calculated values
- Authentication required for all endpoints
- Error responses (404, 401, 400) handled gracefully

---

### C. Data Validation Testing

**Rationale:** Ensure backend calculations match expected medical formulas and iOS displays them correctly.

**Methodology:** Unit tests for calculation methods + manual verification

**Justification:**
- Health metrics require medical accuracy
- Calculations must match established formulas (BMI, TDEE, RMR, etc.)
- Display formatting must be correct (decimal places, units)

**Test Scope:**
- BMI calculation matches formula: weight (kg) / (height (m))²
- TDEE calculation matches RMR × activity level
- RMR calculation matches Mifflin-St Jeor equation
- Waist-to-Hip ratio calculation: waist / hip
- All ratios formatted to correct decimal places
- Null/optional values handled correctly

---

### D. UI/UX Testing

**Rationale:** Verify user can input and view health metrics intuitively and all UI elements match design system.

**Methodology:** Manual usability testing + visual inspection

**Justification:**
- App must be usable by non-technical users
- UI must match existing app design patterns
- Accessibility should be maintained
- User experience should be smooth and intuitive

**Test Scope:**
- Form input fields accept correct data types
- Validation errors display clearly
- Visual design matches existing app (colors, fonts, spacing)
- Navigation flows are intuitive
- Buttons and interactive elements are easily tappable
- Empty states guide users to next action
- Loading indicators show during API calls

---

### E. Error Handling Testing

**Rationale:** App must handle network errors, missing data, and API errors gracefully.

**Methodology:** Manual testing + automated error simulation

**Justification:**
- Real-world apps must handle failures gracefully
- Users should see helpful error messages
- App should not crash on errors
- Network failures should allow retry

**Test Scope:**
- Network errors display user-friendly messages
- Missing health metrics shows appropriate empty state
- Invalid form input shows validation errors
- API errors (400, 401, 404, 500) handled correctly
- Token expiration triggers re-authentication
- Rate limiting handled gracefully

---

## Test Resources

### Hardware
- iOS Simulator (multiple device types)
- Real iPhone (if available) for device-specific testing
- Mac for development and testing

### Software
- Xcode 15+ with iOS 17+ Simulator
- Postman/curl for API verification
- Git for version control and build tracking

### Test Data
- Test user accounts with known profile data
- Sample health metrics data for testing
- Edge case data (very high/low values, missing fields)

---

## Test Environment Setup

1. **Backend API:** Production URL (https://adaptfitness-production.up.railway.app)
2. **iOS App:** Latest build from current branch
3. **Test User:** Create dedicated test account
4. **Test Data:** Pre-populate with known health metrics entries

---

## Test Execution Strategy

1. **Initial Build Testing:** Test all features on first build
2. **Regression Testing:** Re-test after bug fixes on subsequent builds
3. **Continuous Testing:** Run tests on each build to track pass/fail evolution
4. **Documentation:** Record all results

---

## Risk Assessment

**High Risk:**
- API calculation accuracy (medical formulas must be correct)
- Data loss during create/update operations
- Authentication token expiration handling

**Medium Risk:**
- UI inconsistencies with existing app design
- Performance with large datasets
- Network timeout handling

**Low Risk:**
- Minor UI layout issues
- Formatting inconsistencies
- Edge case data handling

---

## Test Completion Criteria

All test categories must achieve:
- **Functional Testing:** 100% of test cases pass
- **API Integration:** All endpoints tested and verified
- **Data Validation:** All calculations verified against formulas
- **UI/UX:** All design patterns match existing app
- **Error Handling:** All error scenarios handled gracefully

---

## Research on Testing Methodologies

### Why Manual Testing for UI?
- **Visual Verification Required:** UI rendering, colors, spacing, layout require human observation
- **Touch Interactions:** Simulator touch interactions don't perfectly match real devices
- **Real Device Testing:** Hardware-specific features (camera, sensors) need real devices
- **Industry Standard:** Most iOS apps use manual testing for UI (Apple's own apps use manual testing extensively)

**References:**
- Apple's Human Interface Guidelines recommend manual testing
- iOS testing best practices from WWDC sessions

### Why E2E Tests for API Integration?
- **Complete Flow Verification:** Tests entire request → response cycle
- **Authentication Testing:** Verifies JWT tokens work correctly
- **Real Backend Testing:** Tests against actual database and calculations
- **Regression Prevention:** Catches breaking changes in API contracts

**References:**
- Supertest documentation: https://github.com/visionmedia/supertest
- NestJS testing best practices

### Why Manual Verification for Calculations?
- **Medical Accuracy Critical:** Health calculations must match medical formulas exactly
- **Complex Formulas:** Some formulas (ABSI, TDEE) require manual verification
- **User Safety:** Incorrect health calculations could mislead users about their health

**References:**
- Medical calculation formulas from health organizations
- Fitness industry standards for metabolic calculations

---


