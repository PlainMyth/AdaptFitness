# Pull Request: Meal Tracking Improvements and Bug Fixes

## Summary
This PR addresses several critical bugs and implements performance optimizations for the meal tracking feature, including improved API handling, UI/UX enhancements, and better error handling.

## Changes Made

### 🐛 Bug Fixes

#### 1. Fixed Internal Server Calls Locally
- **Issue**: Backend server calls were failing due to authentication token expiration and improper error handling
- **Fix**: 
  - Implemented `handleTokenExpiration()` method in `AuthManager` to properly clear authentication state
  - Added comprehensive error handling for 401 Unauthorized errors across all meal-related views
  - Fixed date parsing to handle ISO8601 formats with and without fractional seconds
  - Added proper response DTO transformation to convert DECIMAL values from PostgreSQL to numbers

#### 2. Fixed Barcode Widget Positioning
- **Issue**: Confirmation dialog appeared in the center of the screen instead of near the barcode button
- **Fix**: 
  - Replaced `confirmationDialog` with `popover` that attaches to the barcode button
  - Configured popover to appear at `.topTrailing` anchor point with arrow pointing to button
  - Improved UI with icons and better styling for clarity

#### 3. Fixed Macro Tracker Circles
- **Issue**: Macro progress circles were not updating to reflect consumed amounts
- **Fix**:
  - Updated macro goals to show consumed/goal format (e.g., "7/150 g" instead of "150 g left")
  - Added Calories circle to the macro tracker
  - Fixed date filtering to properly identify today's meals
  - Circles now dynamically update based on real-time meal data

### ⚡ Performance Optimizations

#### 4. Optimized OpenFoodFacts API Calls
- **Issue**: Food search was extremely slow (15+ seconds) and timing out
- **Fixes**:
  - **Added Caching**: Implemented in-memory cache with 5-minute TTL for search results
  - **Reduced Data Transfer**: 
    - Reduced page size from 20 to 15 items
    - Added `sort_by: 'popularity'` for better, faster results
  - **Increased Timeouts**: 
    - Backend timeout increased to 15 seconds
    - iOS app timeout increased from 10 to 20 seconds
  - **Better Error Handling**: Added specific handling for timeout errors (504 Gateway Timeout)
  - **Task Cancellation**: Properly handle cancelled search tasks during debouncing to prevent error messages

### 🧪 Testing & Error Handling

#### 5. Added Connection Loss Error Handling
- **Issue**: App didn't handle network connection loss gracefully
- **Fixes**:
  - Added comprehensive `URLError` handling for:
    - `notConnectedToInternet`
    - `timedOut`
    - `cannotConnectToHost`
    - `cannotFindHost`
  - Implemented user-friendly error messages for each scenario
  - Added proper cancellation error handling to prevent false error messages
  - Tested all error scenarios manually to ensure proper behavior

#### 6. Extended Lossless Resources & Data Persistence
- **Issue**: Meal data was being lost or not properly persisted
- **Fixes**:
  - Fixed meal refresh logic to ensure meals appear immediately after adding
  - Added `onMealAdded` callback to notify parent views when meals are created
  - Implemented proper date parsing with fallback for different ISO8601 formats
  - Added debug logging for meal loading and date filtering

### 🎨 UI/UX Improvements

#### 7. Meal Organization by Type
- Grouped meals by meal type (Breakfast, Lunch, Dinner, Snack, Other)
- Added meal type icons and headers for each section
- Improved visual hierarchy and organization

#### 8. Delete Meal Functionality
- Added ability to delete meals by tapping on meal cards
- Implemented confirmation dialog before deletion
- Added API endpoint for meal deletion

#### 9. Fixed Deprecated APIs
- Updated all `onChange(of:perform:)` to iOS 17+ syntax with `oldValue, newValue` parameters
- Fixed nil coalescing operator warnings for non-optional types
- Resolved async/await error handling issues

## Technical Details

### Backend Changes
- **File**: `adaptfitness-backend/src/meal/food.service.ts`
  - Added 15-second timeout for OpenFoodFacts API calls
  - Implemented in-memory caching with automatic cleanup
  - Added timeout error detection and proper error responses

- **File**: `adaptfitness-backend/src/meal/meal.controller.ts`
  - Added `MealResponseDto` for proper serialization
  - Transforms DECIMAL values to numbers
  - Converts Date objects to ISO8601 strings

- **File**: `adaptfitness-backend/src/meal/meal.entity.ts`
  - Changed all nutrition columns from INTEGER to DECIMAL(10,2)
  - Supports decimal values for accurate nutrition tracking

### iOS Changes
- **File**: `adaptfitness-ios/AdaptFitness/Views/Meal/MealTrackerMainView.swift`
  - Replaced confirmation dialog with popover
  - Added macro goal calculations with consumed/goal format
  - Implemented meal grouping by type
  - Added delete meal functionality

- **File**: `adaptfitness-ios/AdaptFitness/Services/APIService.swift`
  - Increased timeout to 20 seconds for food search
  - Added proper cancellation error handling
  - Improved network error messages

- **File**: `adaptfitness-ios/AdaptFitness/ViewModels/FoodSearchViewModel.swift`
  - Added handling for 504 Gateway Timeout errors
  - Implemented cancellation error detection
  - Reduced default page size to 15

- **File**: `adaptfitness-ios/AdaptFitness/Views/Meal/FoodSelectionView.swift`
  - Reduced debounce time from 1 second to 300ms
  - Added task cancellation to prevent duplicate searches
  - Added immediate search on Enter key press

## Testing

### Manual Testing Performed
- ✅ Verified meal creation and display
- ✅ Tested macro circle updates with real meal data
- ✅ Confirmed popover appears near barcode button
- ✅ Tested food search with caching (first search slow, subsequent instant)
- ✅ Verified error handling for network timeouts
- ✅ Tested meal deletion functionality
- ✅ Confirmed proper date parsing for meals
- ✅ Tested connection loss scenarios
- ✅ Verified data persistence after app restart

### Error Scenarios Tested
- ✅ Network connection loss (`notConnectedToInternet`)
- ✅ Server timeout (15+ seconds)
- ✅ Authentication token expiration (401 errors)
- ✅ Task cancellation during typing
- ✅ Invalid date formats
- ✅ Server unavailable (`cannotConnectToHost`)
- ✅ Extended network outages

## Performance Improvements

- **Food Search**: 
  - First search: ~15 seconds (OpenFoodFacts limitation)
  - Cached searches: < 100ms (instant)
  - Reduced data transfer by ~25% (15 items vs 20)

- **Meal Loading**: 
  - Immediate display after creation
  - Proper refresh on view appearance
  - Optimized date filtering

## Breaking Changes
None - all changes are backward compatible.

## Migration Notes
- Database migration required for `meals` table (INTEGER → DECIMAL columns)
- No iOS app migration needed

## Related Issues
- Fixed 401 Unauthorized errors on meal creation
- Fixed "Bad Request" errors due to missing DTO fields
- Fixed "invalid input syntax for type integer" database errors
- Fixed "Failed to decode response" errors
- Fixed slow food search performance

## Screenshots
(Add screenshots of the improved UI if available)

## Checklist
- [x] Code compiles without errors
- [x] All linter warnings resolved
- [x] Error handling implemented
- [x] Performance optimizations tested
- [x] UI/UX improvements verified
- [x] Backend changes tested
- [x] Database migration tested

---

**Author**: Development Team  
**Date**: December 18, 2024  
**Reviewers**: @team

