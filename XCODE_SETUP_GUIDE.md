# Xcode Setup Guide - Adding iOS Files

**Quick guide to add the new iOS files to your Xcode project**

---

## Files to Add (5 files total):

### Created Files:
```
adaptfitness-ios/AdaptFitness/
├── Core/
│   ├── Network/
│   │   ├── NetworkError.swift       (NEW - 72 lines)
│   │   └── APIService.swift         (NEW - 160 lines)
│   └── Auth/
│       └── AuthManager.swift        (NEW - 189 lines)
└── Views/
    └── Auth/
        └── RegisterView.swift       (NEW - 241 lines)

adaptfitness-ios/AdaptFitness/Views/
└── LoginView.swift                  (MODIFIED - 124 lines)
```

---

## Step-by-Step Instructions:

### Method 1: Add via Xcode (Recommended)

1. **Open Xcode:**
   ```bash
   cd /Users/csuftitan/Downloads/AdaptFitness/AdaptFitness/adaptfitness-ios
   open AdaptFitness.xcodeproj
   ```

2. **Add Core Folder:**
   - Right-click on "AdaptFitness" folder in left sidebar
   - Select "Add Files to AdaptFitness"
   - Navigate to: `adaptfitness-ios/AdaptFitness/Core`
   - Check: "Create folder references" (NOT "Create groups")
   - Check: "Copy items if needed"
   - Click "Add"

3. **Add RegisterView:**
   - Right-click on "Views" folder in left sidebar
   - Select "Add Files to AdaptFitness"
   - Navigate to: `adaptfitness-ios/AdaptFitness/Views/Auth`
   - Select `RegisterView.swift`
   - Check: "Copy items if needed"
   - Click "Add"

4. **Verify LoginView is updated:**
   - Click on `Views/LoginView.swift` in left sidebar
   - It should show the updated version (124 lines)
   - Should include `@StateObject private var authManager = AuthManager.shared` on line 12

5. **Build the project:**
   - Press `Cmd+B` (Build)
   - Should build successfully with 0 errors

---

## Expected Xcode Structure After Adding:

```
AdaptFitness (project root)
├── AdaptFitness (folder)
│   ├── Core/                        ← NEW FOLDER
│   │   ├── Network/
│   │   │   ├── NetworkError.swift
│   │   │   └── APIService.swift
│   │   └── Auth/
│   │       └── AuthManager.swift
│   ├── Views/
│   │   ├── Auth/                    ← NEW FOLDER
│   │   │   └── RegisterView.swift
│   │   └── LoginView.swift          ← MODIFIED
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Workout.swift
│   │   └── ... (other models)
│   ├── Services/
│   ├── Utils/
│   └── AdaptFitnessApp.swift
└── AdaptFitness.xcodeproj
```

---

## Verification Checklist:

### Build Verification:
- [ ] Open Xcode project
- [ ] Add Core folder to project
- [ ] Add RegisterView to Views/Auth
- [ ] Build project (Cmd+B)
- [ ] 0 errors, 0 warnings

### File Verification:
- [ ] Core/Network/NetworkError.swift appears in project navigator
- [ ] Core/Network/APIService.swift appears in project navigator
- [ ] Core/Auth/AuthManager.swift appears in project navigator
- [ ] Views/Auth/RegisterView.swift appears in project navigator
- [ ] Views/LoginView.swift shows updated code

### Code Verification:
- [ ] NetworkError enum compiles
- [ ] APIService.shared singleton accessible
- [ ] AuthManager.shared singleton accessible
- [ ] RegisterView compiles
- [ ] LoginView compiles

---

## Testing in Simulator:

### After adding files, test the app:

1. **Select simulator:**
   - Click simulator dropdown (top left)
   - Select "iPhone 15 Pro" or any iOS 17+ device

2. **Run the app:**
   - Press `Cmd+R` (Run)
   - App should launch in simulator

3. **Test Registration:**
   - App should show LoginView
   - Click "Don't have an account? Sign Up"
   - Should navigate to RegisterView
   - Fill in form:
     - Email: test@example.com
     - Password: TestPass123!
     - First Name: Test
     - Last Name: User
   - Click "Create Account"
   - Should connect to: https://adaptfitness-production.up.railway.app
   - Should register successfully and navigate to home

4. **Test Login:**
   - If already have an account
   - Enter email and password
   - Click "Log In"
   - Should connect to backend
   - Should receive JWT token
   - Should navigate to home

---

## Common Issues & Fixes:

### Issue 1: "No such module 'Combine'"
**Fix:** Combine is built-in to iOS. Make sure deployment target is iOS 13.0+

### Issue 2: "Cannot find 'AuthManager' in scope"
**Fix:** Make sure Core/Auth/AuthManager.swift is added to the target

### Issue 3: "Type 'AuthManager' has no member 'shared'"
**Fix:** Rebuild the project (Cmd+Shift+K, then Cmd+B)

### Issue 4: "Use of unresolved identifier 'NetworkError'"
**Fix:** Make sure Core/Network/NetworkError.swift is added to the target

### Issue 5: App crashes on launch
**Fix:** Check the console for errors. Likely missing files or import issues.

---

## API Connection Details:

### Production Backend:
- **URL:** https://adaptfitness-production.up.railway.app
- **Configured in:** APIService.swift (line 11)

### Endpoints Used:
- POST /auth/register - User registration
- POST /auth/login - User login
- GET /auth/profile - Get user profile (protected)

### Authentication:
- JWT tokens stored in UserDefaults
- Token automatically added to requests via APIService
- Token persists across app launches

---

## Next Steps After Setup:

Once you've added the files and tested registration/login:

1. **Create WorkoutViewModel.swift**
   - Handles workout API calls
   - Manages workout list state
   - Calculates streak

2. **Create WorkoutListView.swift**
   - Displays list of workouts
   - Shows current streak
   - Create workout button

3. **Update HomeView.swift**
   - Display real data from backend
   - Show workout count
   - Show streak

Then you'll have a complete MVP!

---

## Support:

If you encounter issues:
1. Check Build Errors in Xcode (Cmd+9)
2. Clean Build Folder (Cmd+Shift+K)
3. Rebuild (Cmd+B)
4. Check console output when running (Cmd+')

---

**Good luck! Your backend is ready and waiting for the iOS app to connect!**

