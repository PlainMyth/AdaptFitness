# Xcode Setup and Testing Guide

## 📱 Opening the Project in Xcode

### Step 1: Open the Project
```bash
cd adaptfitness-ios
open AdaptFitness.xcodeproj
```

### Step 2: Verify Backend is Running
Make sure your backend server is running:
```bash
cd ../adaptfitness-backend
npm run start:dev
```

Verify it's working:
```bash
curl http://localhost:3000/health
```

### Step 3: Select Simulator
1. In Xcode, click the device selector (top toolbar)
2. Choose an iOS Simulator (e.g., "iPhone 15" or "iPhone 15 Pro")
3. For testing, iPhone 15 is recommended

### Step 4: Build and Run
- Click the **Run** button (▶️) or press `Cmd + R`
- Wait for the build to complete
- The app will launch in the simulator

### Step 5: Verify Connection
- The app should show the Login screen
- Check Xcode Console (bottom panel) for any connection errors
- If you see "connection refused", verify the backend is running

---

## 🧪 Comprehensive Test Plans

These test plans simulate real user scenarios and common issues.

---

## 📋 Test Plan 1: New User Onboarding Journey

### Objective: Test complete registration and initial setup flow

#### **Test Case 1.1: User Registration**
**Steps:**
1. Launch app → Should show Login screen
2. Tap "Don't have an account? Sign up"
3. Fill in registration form:
   - Email: `testuser@example.com`
   - Password: `TestPass123!` (meets requirements)
   - First Name: `Test`
   - Last Name: `User`
   - Date of Birth: `01/01/1990`
   - Height: `175` cm
   - Weight: `70` kg
   - Gender: `Male`
   - Activity Level: `Moderate`
4. Tap "Register"

**Expected Results:**
- ✅ Successfully creates account
- ✅ Automatically logs in
- ✅ Redirects to Home screen
- ✅ No error messages

**Potential Issues to Check:**
- ❌ Password validation errors (too weak)
- ❌ Email already exists error
- ❌ Network timeout if backend is down
- ❌ Form validation (empty fields)

---

#### **Test Case 1.2: Weak Password Registration**
**Steps:**
1. Go to Register screen
2. Enter weak passwords:
   - `password` (too simple)
   - `123456` (no uppercase/special)
   - `Password` (no number/special)
   - `Password1` (no special char)
3. Attempt to register

**Expected Results:**
- ✅ Shows specific password requirements error
- ✅ Doesn't allow registration
- ✅ Error message explains missing requirements

---

#### **Test Case 1.3: Duplicate Email Registration**
**Steps:**
1. Register with `testuser@example.com` (from 1.1)
2. Logout (if possible)
3. Try registering again with same email

**Expected Results:**
- ✅ Shows "Email already exists" error
- ✅ User cannot create duplicate account
- ✅ Can proceed to login instead

---

## 📋 Test Plan 2: Authentication Flow

### Objective: Test login, logout, session management

#### **Test Case 2.1: Successful Login**
**Steps:**
1. From Login screen
2. Enter credentials:
   - Email: `testuser@example.com`
   - Password: `TestPass123!`
3. Optionally check "Remember Me"
4. Tap "Login"

**Expected Results:**
- ✅ Logs in successfully
- ✅ Navigates to Home screen
- ✅ Shows user's data
- ✅ Token is stored securely

**Potential Issues:**
- ❌ Wrong credentials error
- ❌ Network connection timeout
- ❌ App crashes on invalid response

---

#### **Test Case 2.2: Invalid Credentials**
**Steps:**
1. Enter wrong email: `wrong@example.com`
2. Enter correct password: `TestPass123!`
3. Tap Login

**Then:**
4. Enter correct email
5. Enter wrong password: `WrongPass123!`
6. Tap Login

**Expected Results:**
- ✅ Shows "Invalid credentials" error message
- ✅ Login button is disabled during loading
- ✅ User can retry after error
- ✅ Password field is cleared (security)

---

#### **Test Case 2.3: Empty Form Validation**
**Steps:**
1. Leave email empty, password empty
2. Tap Login button

**Expected Results:**
- ✅ Login button is disabled/grayed out
- ✅ Cannot submit empty form
- ✅ No network request sent

---

#### **Test Case 2.4: Network Failure Handling**
**Steps:**
1. Stop the backend server (`Ctrl+C` in backend terminal)
2. Try to login with valid credentials
3. Observe error handling

**Expected Results:**
- ✅ Shows network error message
- ✅ Doesn't crash the app
- ✅ User can retry after backend is restarted

**After Test:**
4. Restart backend server
5. Verify login works again

---

## 📋 Test Plan 3: Home Screen and Goals

### Objective: Test home screen, goal creation, and progress tracking

#### **Test Case 3.1: View Home Screen**
**Steps:**
1. Login successfully
2. Navigate to Home tab

**Expected Results:**
- ✅ Shows user's login streak (flame icon)
- ✅ Displays horizontal calendar with current week
- ✅ Shows existing goals in horizontal scroll
- ✅ Shows meals/workouts section
- ✅ Floating action button visible (for barcode/camera)

---

#### **Test Case 3.2: Create a New Goal**
**Steps:**
1. On Home screen, scroll goals horizontally
2. Tap "Add Goal" button
3. Fill in goal form:
   - Goal Type: Select from dropdown (e.g., "Workout Count")
   - Target Value: `5`
   - Description: `Complete 5 workouts this week`
   - Week Start: Current Monday
   - Week End: Current Sunday
   - Is Active: `true`
4. Tap "Save" or "Create Goal"

**Expected Results:**
- ✅ Goal is created successfully
- ✅ New goal appears in horizontal scroll
- ✅ Goal shows correct target value
- ✅ Goal appears in Goal Calendar view

**Potential Issues:**
- ❌ Form validation errors
- ❌ Date selection not working
- ❌ Goal not appearing after creation

---

#### **Test Case 3.3: View Goal Progress**
**Steps:**
1. Navigate to Home screen
2. View goals in horizontal scroll
3. Tap on an existing goal tile

**Expected Results:**
- ✅ Shows goal details
- ✅ Displays current progress vs target
- ✅ Shows percentage completion
- ✅ Updates as workouts/meals are logged

---

#### **Test Case 3.4: Goal Calendar View**
**Steps:**
1. Navigate to Goals/Calendar section (if available)
2. View calendar layout
3. Tap on different weeks

**Expected Results:**
- ✅ Calendar displays correctly
- ✅ Goals show for correct week
- ✅ Progress updates reflect actual data
- ✅ Navigation between weeks works

---

## 📋 Test Plan 4: Workout Management

### Objective: Test workout logging, viewing, and streak tracking

#### **Test Case 4.1: Add a New Workout**
**Steps:**
1. Navigate to "Workouts" tab
2. Tap "Add Workout" or "+" button
3. Fill in workout form:
   - Name: `Morning Run`
   - Description: `5K run in the park`
   - Start Time: Today, 7:00 AM
   - End Time: Today, 7:45 AM
   - Duration: `45` minutes
   - Calories Burned: `350`
   - Workout Type: `Cardio`
   - Is Completed: `true`
4. Save workout

**Expected Results:**
- ✅ Workout is created successfully
- ✅ Appears in workout list
- ✅ Duration and calories are correct
- ✅ Workout type is displayed
- ✅ Updates goal progress automatically

---

#### **Test Case 4.2: View Workout List**
**Steps:**
1. Navigate to Workouts tab
2. View list of workouts

**Expected Results:**
- ✅ Shows all workouts (chronological order)
- ✅ Displays workout name, date, type
- ✅ Shows duration and calories
- ✅ Can tap to view details
- ✅ Pull to refresh works (if implemented)

---

#### **Test Case 4.3: View Workout Details**
**Steps:**
1. Tap on a workout from the list
2. View workout details screen

**Expected Results:**
- ✅ Shows complete workout information
- ✅ Displays all fields (duration, calories, sets, reps, etc.)
- ✅ Edit/Delete buttons available (if implemented)
- ✅ Can navigate back to list

---

#### **Test Case 4.4: Workout Streak Tracking**
**Steps:**
1. Create multiple workouts:
   - Workout today
   - Workout yesterday
   - Workout 2 days ago
   - Skip 3 days ago
   - Workout 4 days ago
2. Navigate to Home screen
3. Check streak indicator

**Expected Results:**
- ✅ Streak calculates correctly (3 days)
- ✅ Streak updates when new workout added
- ✅ Streak resets if day is missed
- ✅ Displays in flame icon on Home

**Edge Cases:**
- Multiple workouts same day = 1 day count
- Workouts at different times
- Timezone handling

---

#### **Test Case 4.5: Different Workout Types**
**Steps:**
1. Create workouts with different types:
   - `Cardio` (running, cycling)
   - `Strength` (weightlifting)
   - `Flexibility` (yoga, stretching)
   - `Sports` (basketball, tennis)
   - `Other`
2. Verify each saves correctly

**Expected Results:**
- ✅ Each workout type is saved properly
- ✅ Type is displayed in list
- ✅ Can filter by type (if implemented)

---

#### **Test Case 4.6: Incomplete Workout**
**Steps:**
1. Start creating a workout
2. Fill partial data:
   - Name only
   - Or start time but no end time
3. Attempt to save

**Expected Results:**
- ✅ Form validation prevents invalid data
- ✅ Required fields are marked
- ✅ Error messages are clear

---

## 📋 Test Plan 5: Meal Logging

### Objective: Test meal creation, food search, and barcode scanning

#### **Test Case 5.1: Add a Simple Meal**
**Steps:**
1. Navigate to Meals section (if separate tab) or Home
2. Tap "Add Meal"
3. Fill in meal form:
   - Name: `Breakfast`
   - Meal Type: `Breakfast`
   - Meal Time: Today, 8:00 AM
   - Calories: `450`
   - Description: `Oatmeal with fruit`
4. Save meal

**Expected Results:**
- ✅ Meal is created successfully
- ✅ Appears in meal list
- ✅ Updates meal streak counter
- ✅ Updates daily calorie totals

---

#### **Test Case 5.2: Food Search (OpenFoodFacts Integration)**
**Steps:**
1. Navigate to Add Meal
2. Look for "Search Foods" or food search field
3. Search for: `apple`
4. View search results
5. Select a food item from results

**Expected Results:**
- ✅ Shows list of foods from OpenFoodFacts
- ✅ Displays food name, brand, calories
- ✅ Can select food to add to meal
- ✅ Food data populates meal form
- ✅ Pagination works (if multiple pages)

**Potential Issues:**
- ❌ No results found
- ❌ Network timeout
- ❌ Slow loading
- ❌ Invalid food data

---

#### **Test Case 5.3: Barcode Scanning**
**Steps:**
1. From Add Meal or Home screen
2. Tap barcode scanner button (camera icon)
3. Point camera at product barcode
4. Wait for scan to complete

**Expected Results:**
- ✅ Camera opens (in simulator, may need manual input)
- ✅ Barcode is detected/recognized
- ✅ Product information is fetched
- ✅ Food details are displayed
- ✅ Can add to meal

**Simulator Note:**
- iOS Simulator doesn't have real camera
- Test barcode: `3017620422003` (Nutella)
- Or use manual barcode entry (if implemented)

**Potential Issues:**
- ❌ Camera permission not granted
- ❌ Barcode not recognized
- ❌ Product not found in database
- ❌ Network error during lookup

---

#### **Test Case 5.4: Meal Streak Tracking**
**Steps:**
1. Log meals for consecutive days:
   - Meal today
   - Meal yesterday
   - Meal 2 days ago
   - Skip 3 days ago
2. Check streak counter

**Expected Results:**
- ✅ Streak counts correctly
- ✅ Updates as meals are logged
- ✅ Resets if day is missed
- ✅ Displays in Home screen

---

#### **Test Case 5.5: Different Meal Types**
**Steps:**
1. Create meals for different types:
   - `Breakfast`
   - `Lunch`
   - `Dinner`
   - `Snack`
   - `Other`
2. Verify each saves with correct type

**Expected Results:**
- ✅ Each meal type is categorized correctly
- ✅ Can filter by meal type (if implemented)
- ✅ Displayed in meal list with type label

---

#### **Test Case 5.6: Meal with Food Search**
**Steps:**
1. Add Meal → Search for `chicken`
2. Select a chicken product from results
3. Adjust serving size (if available)
4. Save meal

**Expected Results:**
- ✅ Food information is pre-filled
- ✅ Calories calculated from serving size
- ✅ Can edit before saving
- ✅ Meal saves with food details

---

## 📋 Test Plan 6: Profile and Settings

### Objective: Test user profile, account management

#### **Test Case 6.1: View Profile**
**Steps:**
1. Navigate to Profile tab
2. View profile information

**Expected Results:**
- ✅ Displays user email, name
- ✅ Shows user stats (workouts, meals, streaks)
- ✅ Profile picture placeholder (if implemented)
- ✅ Account settings accessible

---

#### **Test Case 6.2: Update Profile**
**Steps:**
1. Navigate to Profile
2. Tap "Edit Profile" or similar
3. Update:
   - First Name
   - Last Name
   - Height
   - Weight
   - Activity Level
4. Save changes

**Expected Results:**
- ✅ Changes are saved successfully
- ✅ Updated info displays in profile
- ✅ Changes persist after app restart

---

#### **Test Case 6.3: Logout**
**Steps:**
1. Navigate to Profile
2. Tap "Logout" button
3. Confirm logout

**Expected Results:**
- ✅ Logs out successfully
- ✅ Returns to Login screen
- ✅ Token is cleared
- ✅ Cannot access protected screens
- ✅ Must login again to access app

---

#### **Test Case 6.4: View Statistics**
**Steps:**
1. Navigate to Profile
2. View statistics section (if available)

**Expected Results:**
- ✅ Shows total workouts
- ✅ Shows total meals logged
- ✅ Shows current streaks
- ✅ Shows goal completion rates
- ✅ Displays health metrics (if available)

---

## 📋 Test Plan 7: Error Handling and Edge Cases

### Objective: Test app behavior under error conditions

#### **Test Case 7.1: Network Interruption**
**Steps:**
1. Start an action (e.g., adding workout)
2. Disconnect internet (Airplane Mode or disable WiFi)
3. Attempt to save

**Expected Results:**
- ✅ Shows network error message
- ✅ Doesn't crash
- ✅ Action can be retried when connection restored
- ✅ User data isn't lost (if saved locally first)

---

#### **Test Case 7.2: Backend Server Down**
**Steps:**
1. Stop backend server
2. Try various actions:
   - Login
   - Add workout
   - View meals
   - Search foods

**Expected Results:**
- ✅ Shows appropriate error messages
- ✅ App doesn't crash
- ✅ User can retry after server is back up
- ✅ Graceful degradation (shows cached data if available)

---

#### **Test Case 7.3: Invalid Data Handling**
**Steps:**
1. Try entering invalid data:
   - Negative calories
   - Future dates for past workouts
   - Negative weight/height
   - Text in numeric fields
2. Attempt to save

**Expected Results:**
- ✅ Form validation prevents invalid input
- ✅ Clear error messages
- ✅ Cannot save invalid data
- ✅ Fields highlight errors

---

#### **Test Case 7.4: Rapid Button Tapping**
**Steps:**
1. Rapidly tap "Login" button multiple times
2. Rapidly tap "Add Workout" button

**Expected Results:**
- ✅ Prevents duplicate submissions
- ✅ Loading state disables button
- ✅ Only one request sent
- ✅ No duplicate data created

---

#### **Test Case 7.5: Token Expiration**
**Steps:**
1. Login successfully
2. Wait for token to expire (or manually invalidate)
3. Try to perform an action (add workout, view meals)

**Expected Results:**
- ✅ Detects expired token
- ✅ Shows "Session expired" message
- ✅ Redirects to login
- ✅ User can login again

---

## 📋 Test Plan 8: Performance and UI/UX

### Objective: Test app performance and user experience

#### **Test Case 8.1: Loading States**
**Steps:**
1. Perform actions that require network:
   - Login
   - Add workout
   - Search foods
   - Load workout list

**Expected Results:**
- ✅ Shows loading indicators
- ✅ Buttons disabled during loading
- ✅ User can't accidentally double-submit
- ✅ Loading states are clear

---

#### **Test Case 8.2: Data Refresh**
**Steps:**
1. Add a workout from one screen
2. Navigate to workout list
3. Verify new workout appears

**Expected Results:**
- ✅ Data refreshes automatically
- ✅ New items appear in lists
- ✅ No need to restart app
- ✅ Pull-to-refresh works (if implemented)

---

#### **Test Case 8.3: Navigation Flow**
**Steps:**
1. Navigate through all tabs:
   - Home → Workouts → Profile
   - Home → Meals → Profile
   - Workouts → Add Workout → Back to List
2. Test back button behavior

**Expected Results:**
- ✅ Navigation is smooth
- ✅ Back buttons work correctly
- ✅ Tab state persists
- ✅ No navigation bugs

---

#### **Test Case 8.4: Large Data Sets**
**Steps:**
1. Create many workouts (20+)
2. Create many meals (20+)
3. Scroll through lists

**Expected Results:**
- ✅ Lists load efficiently
- ✅ Smooth scrolling
- ✅ Pagination works (if implemented)
- ✅ No memory issues
- ✅ App remains responsive

---

## 📋 Test Plan 9: Integration Testing

### Objective: Test complete user workflows

#### **Test Case 9.1: Complete Daily Workflow**
**Steps:**
1. **Morning:**
   - Login
   - Log breakfast meal
   - View daily goals
   
2. **Afternoon:**
   - Log workout (running)
   - Check workout streak
   
3. **Evening:**
   - Log dinner meal
   - Search for food item
   - Check goal progress
   - View profile stats

**Expected Results:**
- ✅ All data saves correctly
- ✅ Goals update with progress
- ✅ Streaks calculate correctly
- ✅ All features work together
- ✅ Data persists across app restarts

---

#### **Test Case 9.2: Goal Achievement Flow**
**Steps:**
1. Create goal: "Complete 3 workouts this week"
2. Complete workout 1
3. Check goal progress (should show 1/3)
4. Complete workout 2
5. Check goal progress (should show 2/3)
6. Complete workout 3
7. Verify goal shows as completed (3/3)

**Expected Results:**
- ✅ Goal progress updates after each workout
- ✅ Shows correct percentage
- ✅ Goal marked as complete when target reached
- ✅ Celebration/notification (if implemented)

---

#### **Test Case 9.3: Multi-Day Streak Building**
**Steps:**
1. **Day 1:** Log workout, log meal
2. **Day 2:** Log workout, log meal (streak = 2)
3. **Day 3:** Log workout, log meal (streak = 3)
4. **Day 4:** Skip workout, skip meal
5. **Day 5:** Log workout, log meal (streak resets to 1)

**Expected Results:**
- ✅ Streaks increment correctly
- ✅ Streaks reset when day is missed
- ✅ Multiple activities same day count as 1
- ✅ Streaks display correctly on Home

---

## 📋 Test Plan 10: Platform-Specific Testing

### Objective: Test iOS-specific features

#### **Test Case 10.1: App Backgrounding**
**Steps:**
1. Login and navigate to app
2. Press Home button (swipe up on newer iPhones)
3. Wait 30 seconds
4. Return to app

**Expected Results:**
- ✅ App resumes correctly
- ✅ Session still valid
- ✅ Data persists
- ✅ No crashes

---

#### **Test Case 10.2: App Termination**
**Steps:**
1. Login successfully
2. Force quit app (swipe up in app switcher)
3. Reopen app

**Expected Results:**
- ✅ If "Remember Me" was checked: Auto-login
- ✅ If not: Returns to login screen
- ✅ No data loss
- ✅ App launches correctly

---

#### **Test Case 10.3: Different Screen Sizes**
**Steps:**
1. Test on different simulators:
   - iPhone SE (small)
   - iPhone 15 (medium)
   - iPhone 15 Pro Max (large)
   - iPad (if supported)

**Expected Results:**
- ✅ Layout adapts correctly
- ✅ All UI elements visible
- ✅ No text truncation
- ✅ Touch targets are adequate size

---

#### **Test Case 10.4: Dark Mode**
**Steps:**
1. Enable Dark Mode in iOS Settings
2. Open app
3. Navigate through all screens

**Expected Results:**
- ✅ App supports dark mode (if implemented)
- ✅ Text is readable
- ✅ Colors contrast properly
- ✅ No UI glitches

---

## 🐛 Common Issues to Watch For

### Authentication Issues
- ❌ Token not being saved
- ❌ Token not sent in requests
- ❌ Auto-login not working
- ❌ Session expiration not handled

### Data Sync Issues
- ❌ Data not saving to backend
- ❌ Duplicate entries created
- ❌ Data not refreshing after save
- ❌ Offline data not syncing

### UI Issues
- ❌ Buttons not responding
- ❌ Forms not validating
- ❌ Loading states stuck
- ❌ Navigation bugs
- ❌ Keyboard covering inputs

### Performance Issues
- ❌ Slow loading times
- ❌ App freezes
- ❌ Memory leaks
- ❌ Battery drain

### Network Issues
- ❌ No error handling for network failures
- ❌ Retry logic not working
- ❌ Timeout handling missing
- ❌ SSL/TLS errors

---

## 📊 Test Checklist Summary

### ✅ Pre-Testing Checklist
- [ ] Backend server is running on localhost:3000
- [ ] Backend health check passes
- [ ] Xcode project opens without errors
- [ ] App builds successfully
- [ ] Simulator is selected and ready

### ✅ Authentication
- [ ] Registration works
- [ ] Login works
- [ ] Password validation works
- [ ] Error handling works
- [ ] Logout works

### ✅ Core Features
- [ ] Workout creation
- [ ] Workout viewing
- [ ] Meal creation
- [ ] Food search
- [ ] Goal creation
- [ ] Goal progress tracking

### ✅ Data Persistence
- [ ] Data saves to backend
- [ ] Data loads from backend
- [ ] Data persists after app restart
- [ ] Streaks calculate correctly

### ✅ Error Handling
- [ ] Network errors handled
- [ ] Invalid input rejected
- [ ] Token expiration handled
- [ ] App doesn't crash

### ✅ UI/UX
- [ ] Loading states shown
- [ ] Navigation works smoothly
- [ ] Forms validate correctly
- [ ] Error messages are clear

---

## 🎯 Priority Testing Order

### **High Priority (Must Test First)**
1. Authentication (Login/Register)
2. Workout creation and viewing
3. Meal creation
4. Goal creation and progress
5. Error handling

### **Medium Priority**
6. Food search and barcode
7. Streak tracking
8. Profile management
9. Data refresh

### **Low Priority (Nice to Have)**
10. Dark mode
11. Different screen sizes
12. Performance with large datasets
13. Advanced features

---

## 📝 Testing Tips

1. **Keep Xcode Console Open**: Watch for errors and network requests
2. **Use Network Inspector**: In Xcode, use Network tool to see API calls
3. **Test on Multiple Devices**: Different simulators catch layout issues
4. **Test Both Success and Failure**: Don't just test happy paths
5. **Document Bugs**: Note issues with steps to reproduce
6. **Test Incrementally**: Test one feature at a time
7. **Restart App**: Test persistence by closing and reopening
8. **Clear App Data**: Test fresh installs occasionally

---

## 🔧 Troubleshooting Common Setup Issues

### Issue: App won't connect to backend
**Solution:**
- Verify backend is running: `curl http://localhost:3000/health`
- Check Xcode console for connection errors
- Verify APIService.swift baseURL is `http://localhost:3000`

### Issue: Build errors
**Solution:**
- Clean build folder: `Cmd + Shift + K`
- Restart Xcode
- Check for missing dependencies

### Issue: Simulator is slow
**Solution:**
- Close other apps
- Use iPhone 15 instead of Pro Max
- Restart simulator

### Issue: Camera doesn't work in simulator
**Solution:**
- This is expected - simulators don't have real cameras
- Use manual barcode entry or test on real device

---

## 📚 Additional Resources

- **Backend API Docs**: See `adaptfitness-backend/README.md`
- **API Testing Scripts**: `adaptfitness-backend/test-*.sh`
- **Xcode Documentation**: Apple's Xcode User Guide

---

**Happy Testing! 🚀**

