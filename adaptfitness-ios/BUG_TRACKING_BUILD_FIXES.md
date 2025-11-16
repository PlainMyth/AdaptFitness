# Bug Tracking: iOS Build Fixes

## Overview
This document tracks all bugs and fixes related to iOS build errors encountered during the implementation of the Tracking Page, Workout Page, and related features.

---

## Bug #1: Deprecated `onChange` Modifier in iOS 17+

**Status:** Fixed

**Severity:** Warning

**Files Affected:**
- `Views/Workouts/WorkoutListView.swift`
- `Views/Workouts/WorkoutPageView.swift`
- `Views/Stats/TrackingView.swift`

**Description:**
The `onChange(of:perform:)` modifier was deprecated in iOS 17.0. The old single-parameter closure syntax was causing deprecation warnings.

**Error Message:**
```
'onChange(of:perform:)' was deprecated in iOS 17.0: Use `onChange` with a two or zero parameter closure
```

**Root Cause:**
iOS 17+ requires the new `onChange` syntax that accepts either two parameters (oldValue, newValue) or zero parameters.

**Fix Applied:**
Updated all `onChange` modifiers to use the new iOS 17+ syntax:

**Before:**
```swift
.onChange(of: selectedTimeRange) { _ in
    Task {
        await viewModel.fetchWorkouts()
        await mealViewModel.loadMeals()
    }
}
```

**After:**
```swift
.onChange(of: selectedTimeRange) { oldValue, newValue in
    Task {
        await viewModel.fetchWorkouts()
        mealViewModel.loadMeals()
    }
}
```

**Files Modified:**
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutListView.swift` (line 36)
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutPageView.swift` (line 35)
- `adaptfitness-ios/AdaptFitness/Views/Stats/TrackingView.swift` (line 34)

---

## Bug #2: Incorrect `await` Usage on Non-Async Function

**Status:** Fixed

**Severity:** Warning

**Files Affected:**
- `Views/Workouts/WorkoutListView.swift` (4 instances)
- `Views/Workouts/WorkoutPageView.swift` (2 instances)
- `Views/Stats/TrackingView.swift` (3 instances)

**Description:**
The `loadMeals()` function in `MealViewModel` is not marked as `async`. It creates a `Task` internally, so using `await` on it causes a warning that no async operations occur within the await expression.

**Error Message:**
```
No 'async' operations occur within 'await' expression
```

**Root Cause:**
The `loadMeals()` method signature is:
```swift
func loadMeals() {
    Task {
        // async work here
    }
}
```

Since it's not marked as `async`, calling it with `await` is incorrect.

**Fix Applied:**
Removed `await` keyword from all `loadMeals()` calls:

**Before:**
```swift
await mealViewModel.loadMeals()
```

**After:**
```swift
mealViewModel.loadMeals()
```

**Files Modified:**
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutListView.swift` (lines 39, 113, 132, 137)
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutPageView.swift` (lines 38, 119, 123)
- `adaptfitness-ios/AdaptFitness/Views/Stats/TrackingView.swift` (lines 37, 161, 165)

---

## Bug #3: Date to String Type Conversion Error

**Status:** Fixed

**Severity:** Error

**Files Affected:**
- `Views/Workouts/WorkoutListView.swift`
- `Views/Workouts/WorkoutPageView.swift`
- `Views/Stats/TrackingView.swift` (2 instances)

**Description:**
The code was attempting to parse `workout.startTime` as a String using `parseDate(from:)`, but `WorkoutResponse.startTime` is already a `Date` type, not a `String`.

**Error Message:**
```
Cannot convert value of type 'Date' to expected argument type 'String'
```

**Root Cause:**
The `WorkoutResponse` struct defines `startTime` as `Date`:
```swift
struct WorkoutResponse: Codable, Identifiable {
    let startTime: Date  // Already a Date, not String
    // ...
}
```

But the filtering code was trying to parse it as if it were a String:
```swift
if let workoutDate = parseDate(from: workout.startTime) {
    // parseDate expects String, but startTime is Date
}
```

**Fix Applied:**
Changed the filtering logic to directly compare `Date` objects:

**Before:**
```swift
return workoutViewModel.workouts.filter { workout in
    if let workoutDate = parseDate(from: workout.startTime) {
        return workoutDate >= startDate
    }
    return false
}
```

**After:**
```swift
return workoutViewModel.workouts.filter { workout in
    // workout.startTime is already a Date, not a String
    return workout.startTime >= startDate
}
```

**Files Modified:**
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutListView.swift` (line 194)
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutPageView.swift` (line 145)
- `adaptfitness-ios/AdaptFitness/Views/Stats/TrackingView.swift` (lines 187, 196)

**Additional Changes:**
- Removed unused `parseDate` helper function from `WorkoutPageView.swift` and `TrackingView.swift`

---

## Bug #4: Invalid Redeclaration of `WorkoutHistoryRow`

**Status:** Fixed

**Severity:** Error

**Files Affected:**
- `Views/Workouts/WorkoutPageView.swift`

**Description:**
The `WorkoutHistoryRow` struct was defined in multiple files, causing a redeclaration error. It was already defined in `Views/Stats/TrackingView.swift` and was incorrectly redefined in `Views/Workouts/WorkoutPageView.swift`.

**Error Message:**
```
Invalid redeclaration of 'WorkoutHistoryRow'
```

**Root Cause:**
`WorkoutHistoryRow` was defined in both:
- `Views/Stats/TrackingView.swift` (line 295)
- `Views/Workouts/WorkoutPageView.swift` (line 233)

Since both files are in the same module, this caused a naming conflict.

**Fix Applied:**
Removed the duplicate `WorkoutHistoryRow` definition from `WorkoutPageView.swift`. The struct is now only defined in `TrackingView.swift` and is accessible throughout the module.

**Before:**
```swift
// In WorkoutPageView.swift
struct WorkoutHistoryRow: View {
    // ... implementation
}
```

**After:**
Removed the duplicate definition. `WorkoutPageView` now uses the `WorkoutHistoryRow` from `TrackingView.swift`.

**Files Modified:**
- `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutPageView.swift` (removed lines 233-275)

---

## Bug #5: Ambiguous `CalorieDataPoint` Type Lookup

**Status:** Fixed (Previously)

**Severity:** Error

**Files Affected:**
- `Views/Stats/TrackingView.swift`
- `Views/Workouts/WorkoutListView.swift`
- `Views/Workouts/WorkoutPageView.swift`

**Description:**
The `CalorieDataPoint` struct was defined in multiple files, causing ambiguous type lookup errors.

**Error Message:**
```
'CalorieDataPoint' is ambiguous for type lookup in this context
Invalid redeclaration of 'CalorieDataPoint'
```

**Root Cause:**
`CalorieDataPoint` was defined in:
- `Views/Stats/TrackingView.swift`
- `Views/Workouts/WorkoutListView.swift`
- `Views/Workouts/WorkoutPageView.swift`

**Fix Applied:**
Created a shared model file `Models/ChartModels.swift` containing the `CalorieDataPoint` struct, and removed duplicate definitions from all view files.

**Files Modified:**
- Created: `adaptfitness-ios/AdaptFitness/Models/ChartModels.swift`
- Updated: `Views/Stats/TrackingView.swift` (removed duplicate, added import)
- Updated: `Views/Workouts/WorkoutListView.swift` (removed duplicate, added import)
- Updated: `Views/Workouts/WorkoutPageView.swift` (removed duplicate, added import)

---

## Summary Statistics

**Total Bugs Fixed:** 5 unique bugs (with multiple instances)

**Breakdown by Severity:**
- Errors: 2 bugs (Date/String conversion, Redeclaration)
- Warnings: 2 bugs (Deprecated onChange, Incorrect await)

**Breakdown by File:**
- `WorkoutListView.swift`: 3 bugs (onChange, await x4, Date conversion)
- `WorkoutPageView.swift`: 4 bugs (onChange, await x2, Date conversion, Redeclaration)
- `TrackingView.swift`: 3 bugs (onChange, await x3, Date conversion x2)

**Total Code Changes:**
- Files Modified: 3 view files
- Lines Changed: ~30 lines
- Functions Removed: 2 unused `parseDate` helper functions
- Structs Removed: 1 duplicate `WorkoutHistoryRow` definition

---

## Testing Recommendations

1. **Build Verification:**
   - Verify that all build errors and warnings are resolved
   - Confirm project builds successfully in Xcode

2. **Functionality Testing:**
   - Test time range selector in all three views (WorkoutListView, WorkoutPageView, TrackingView)
   - Verify workout filtering works correctly with date comparisons
   - Confirm charts display correctly with date data
   - Test refresh functionality in all views

3. **Code Quality:**
   - Verify no unused helper functions remain
   - Confirm no duplicate type definitions exist
   - Check that all async/await usage is correct

---

## Related Files

- `adaptfitness-ios/AdaptFitness/ViewModels/MealViewModel.swift` - Contains `loadMeals()` method
- `adaptfitness-ios/AdaptFitness/ViewModels/WorkoutViewModel.swift` - Contains `WorkoutResponse` struct definition
- `adaptfitness-ios/AdaptFitness/Models/ChartModels.swift` - Shared chart data models

---

## Notes

- All fixes maintain backward compatibility with iOS 17+
- The fixes improve code clarity by removing unnecessary type conversions
- Removing duplicate definitions improves code maintainability
- All changes follow Swift best practices for async/await usage

