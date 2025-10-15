<!-- a816aab1-dd70-4c6d-a90b-94acca49a405 345a2cc2-bd1a-40b8-9c8f-1fab7d223917 -->
# AdaptFitness MVP - 1 Week Sprint Plan

## Team Structure & Roles

**Team Member 1 (You)**: Backend Security & API Lead

**Team Member 2**: Backend Features & Testing

**Team Member 3**: iOS Frontend Development

**Timeline**: 7 days to working MVP

**Goal**: Secure, tested backend + basic iOS app that can register users, log workouts, and track streaks

---

## MVP Scope Definition

### What's IN the MVP ✅

- User registration and login (secure)
- Create and view workouts
- View workout streak
- Basic iOS app with authentication
- Deployed backend API
- Security fixes (no exposed secrets)

### What's OUT of MVP ❌

- Meal logging (Phase 2)
- Health metrics calculations (Phase 2)
- Advanced analytics (Phase 2)
- Social features (Phase 2)
- Food scanning (Phase 2)

---

## DAY-BY-DAY BREAKDOWN

### **Day 1 (Monday) - Critical Security Fixes**

**Team Member 1 (You) - 4-5 hours**

- [ ] Update `.gitignore` to exclude `.env` files
- [ ] Remove `.env` from Git tracking
- [ ] Generate new JWT secret (128-char)
- [ ] Create `.env` file with new secrets
- [ ] Remove hardcoded JWT fallbacks (3 files)
- [ ] Add environment validation
- [ ] Test that API fails gracefully without `.env`

**Files to modify**:

```
/.gitignore
/adaptfitness-backend/.env (create new, don't commit)
/adaptfitness-backend/src/app.module.ts (line 58)
/adaptfitness-backend/src/auth/auth.module.ts (line 23)
/adaptfitness-backend/src/auth/strategies/jwt.strategy.ts (line 31)
/adaptfitness-backend/src/config/env.validation.ts (create new)
/adaptfitness-backend/src/main.ts (add validation call)
```

**Team Member 2 - 4-5 hours**

- [ ] Fix password leakage in UserService
- [ ] Create `findByEmailForAuth()` and `findByIdForAuth()` methods
- [ ] Update AuthService to use new methods
- [ ] Update JWT Strategy to use new methods
- [ ] Write tests for new UserService methods
- [ ] Run all existing tests to ensure nothing broke

**Files to modify**:

```
/adaptfitness-backend/src/user/user.service.ts
/adaptfitness-backend/src/auth/auth.service.ts
/adaptfitness-backend/src/auth/strategies/jwt.strategy.ts
/adaptfitness-backend/src/user/user.service.spec.ts (add tests)
```

**Team Member 3 - 4-5 hours**

- [ ] Set up Xcode project for AdaptFitness iOS
- [ ] Create basic project structure (folders)
- [ ] Set up Constants.swift with API base URL
- [ ] Create NetworkError.swift enum
- [ ] Create basic Color scheme and design tokens
- [ ] Set up .gitignore for iOS

**Output**: Security vulnerabilities fixed, iOS project initialized

---

### **Day 2 (Tuesday) - Auth System Polish**

**Team Member 1 (You) - 4-5 hours**

- [ ] Remove all `console.log` statements with sensitive data
- [ ] Add password strength validation
- [ ] Create `PasswordValidator` class
- [ ] Update registration to validate passwords
- [ ] Test password validation (weak passwords rejected)
- [ ] Document password requirements in API docs

**Files to modify**:

```
/adaptfitness-backend/src/auth/strategies/jwt.strategy.ts (remove logs)
/adaptfitness-backend/src/auth/validators/password.validator.ts (create)
/adaptfitness-backend/src/auth/auth.service.ts (add validation)
/adaptfitness-backend/src/auth/auth.service.spec.ts (add tests)
/adaptfitness-backend/README.md (document password rules)
```

**Team Member 2 - 4-5 hours**

- [ ] Simplify workout endpoints for MVP (remove unnecessary features)
- [ ] Ensure workout CRUD works perfectly
- [ ] Test streak calculation thoroughly
- [ ] Write integration tests for workout flow
- [ ] Fix any failing tests
- [ ] Update API documentation

**Files to modify**:

```
/adaptfitness-backend/src/workout/workout.controller.ts
/adaptfitness-backend/src/workout/workout.service.ts
/adaptfitness-backend/src/workout/workout.controller.spec.ts
/adaptfitness-backend/src/workout/workout.service.spec.ts
/adaptfitness-backend/README.md
```

**Team Member 3 - 4-5 hours**

- [ ] Create APIService.swift (networking layer)
- [ ] Create AuthManager.swift (token management)
- [ ] Create KeychainManager.swift (secure token storage)
- [ ] Create User.swift model
- [ ] Test API connection to localhost backend
- [ ] Handle network errors gracefully

**Files to create**:

```
/adaptfitness-ios/AdaptFitness/Core/Network/APIService.swift
/adaptfitness-ios/AdaptFitness/Core/Auth/AuthManager.swift
/adaptfitness-ios/AdaptFitness/Core/Auth/KeychainManager.swift
/adaptfitness-ios/AdaptFitness/Models/User.swift
/adaptfitness-ios/AdaptFitness/Utils/Constants.swift
```

**Output**: Auth system production-ready, iOS networking foundation complete

---

### **Day 3 (Wednesday) - iOS Authentication UI**

**Team Member 1 (You) - 3-4 hours**

- [ ] Test full authentication flow end-to-end
- [ ] Register user → Login → Access protected endpoint
- [ ] Test with invalid credentials
- [ ] Test with weak passwords
- [ ] Document any bugs found
- [ ] Create test user accounts for team

**Testing script**:

```bash
# Create test-auth-flow.sh
# Test registration, login, profile access
# Share with team
```

**Team Member 2 - 4-5 hours**

- [ ] Add rate limiting to auth endpoints
- [ ] Install @nestjs/throttler
- [ ] Configure throttler module
- [ ] Test rate limiting (5 attempts per 15 min)
- [ ] Update API docs with rate limit info
- [ ] Test that legitimate users aren't blocked

**Files to modify**:

```
/adaptfitness-backend/package.json (add dependency)
/adaptfitness-backend/src/app.module.ts (add ThrottlerModule)
/adaptfitness-backend/src/config/throttler.config.ts (create)
/adaptfitness-backend/src/auth/auth.controller.ts (add @Throttle)
/adaptfitness-backend/README.md (document rate limits)
```

**Team Member 3 - 4-5 hours**

- [ ] Create LoginView.swift
- [ ] Create RegisterView.swift
- [ ] Create AuthViewModel.swift
- [ ] Wire up login button to AuthManager
- [ ] Wire up register button to AuthManager
- [ ] Show loading states
- [ ] Show error messages
- [ ] Test full auth flow on simulator

**Files to create**:

```
/adaptfitness-ios/AdaptFitness/Views/Auth/LoginView.swift
/adaptfitness-ios/AdaptFitness/Views/Auth/RegisterView.swift
/adaptfitness-ios/AdaptFitness/ViewModels/AuthViewModel.swift
/adaptfitness-ios/AdaptFitness/AdaptFitnessApp.swift (update)
```

**Output**: Rate limiting active, iOS users can register and login

---

### **Day 4 (Thursday) - Workout Features**

**Team Member 1 (You) - 4-5 hours**

- [ ] Prepare backend for deployment
- [ ] Create Railway account
- [ ] Set up PostgreSQL database on Railway
- [ ] Configure environment variables
- [ ] Test database connection
- [ ] Document deployment process

**Deployment prep**:

```
/adaptfitness-backend/Procfile (create)
/adaptfitness-backend/railway.json (create)
/adaptfitness-backend/package.json (verify engines)
DEPLOYMENT.md (create deployment guide)
```

**Team Member 2 - 4-5 hours**

- [ ] Create comprehensive workout test suite
- [ ] Test workout creation
- [ ] Test workout listing
- [ ] Test streak calculation edge cases
- [ ] Test timezone handling
- [ ] Document all test cases
- [ ] Ensure 80%+ code coverage

**Files to modify**:

```
/adaptfitness-backend/src/workout/workout.e2e-spec.ts (create)
/adaptfitness-backend/test/ (integration tests)
```

**Team Member 3 - 4-5 hours**

- [ ] Create Workout.swift model
- [ ] Create WorkoutViewModel.swift
- [ ] Create WorkoutListView.swift
- [ ] Create CreateWorkoutView.swift
- [ ] Wire up to backend API
- [ ] Show list of workouts
- [ ] Allow creating new workouts
- [ ] Display current streak

**Files to create**:

```
/adaptfitness-ios/AdaptFitness/Models/Workout.swift
/adaptfitness-ios/AdaptFitness/ViewModels/WorkoutViewModel.swift
/adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutListView.swift
/adaptfitness-ios/AdaptFitness/Views/Workouts/CreateWorkoutView.swift
```

**Output**: Backend ready for deployment, iOS workout features working

---

### **Day 5 (Friday) - Deployment & Integration**

**Team Member 1 (You) - 4-5 hours**

- [ ] Deploy backend to Railway
- [ ] Verify all environment variables set
- [ ] Test production API endpoints
- [ ] Set up custom domain (optional)
- [ ] Configure CORS for production
- [ ] Update iOS app with production URL
- [ ] Test end-to-end with production backend

**Deployment**:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Deploy
railway login
railway init
railway up

# Set env vars via dashboard
# Test: curl https://your-app.railway.app/health
```

**Team Member 2 - 4-5 hours**

- [ ] Run full test suite
- [ ] Fix any failing tests
- [ ] Generate test coverage report
- [ ] Review code for obvious bugs
- [ ] Test all API endpoints with Postman/curl
- [ ] Create API test collection
- [ ] Document test results

**Testing checklist**:

```
- [ ] npm test (all pass)
- [ ] npm run test:cov (>80% coverage)
- [ ] Manual API testing
- [ ] Performance testing (basic)
```

**Team Member 3 - 4-5 hours**

- [ ] Create HomeView/Dashboard
- [ ] Show workout count
- [ ] Show current streak
- [ ] Add pull-to-refresh
- [ ] Add loading states
- [ ] Handle offline mode gracefully
- [ ] Test on real iOS device
- [ ] Fix any UI bugs

**Files to create**:

```
/adaptfitness-ios/AdaptFitness/Views/Home/HomeView.swift
/adaptfitness-ios/AdaptFitness/Views/Home/DashboardCard.swift
```

**Output**: Backend deployed to production, iOS app fully functional

---

### **Day 6 (Saturday) - Polish & Bug Fixes**

**ALL TEAM MEMBERS - 3-4 hours each**

**Priorities**:

1. Fix any critical bugs found during testing
2. Improve error messages
3. Add loading indicators where missing
4. Test edge cases
5. Update documentation
6. Prepare demo script

**Specific Tasks**:

**Team Member 1 (You)**:

- [ ] Review and merge any pending PRs
- [ ] Ensure all secrets are rotated
- [ ] Test security (try to break your own app)
- [ ] Update README with production URL
- [ ] Create quick start guide

**Team Member 2**:

- [ ] Write E2E test for complete user journey
- [ ] Test performance under load (basic)
- [ ] Fix any race conditions
- [ ] Optimize slow queries
- [ ] Document API changes

**Team Member 3**:

- [ ] Test app on multiple iOS devices/simulators
- [ ] Fix UI bugs
- [ ] Improve error handling
- [ ] Add haptic feedback
- [ ] Polish animations

**Output**: MVP is stable and polished

---

### **Day 7 (Sunday) - Final Testing & Demo Prep**

**ALL TEAM MEMBERS - 2-3 hours each**

**Final Checklist**:

**Backend**:

- [ ] All tests passing
- [ ] Backend deployed and accessible
- [ ] Health endpoint returns 200
- [ ] Authentication works
- [ ] Workouts can be created/viewed
- [ ] Streak calculation works
- [ ] No secrets in Git history
- [ ] Rate limiting active

**iOS**:

- [ ] App builds successfully
- [ ] Can register new user
- [ ] Can login existing user
- [ ] Can create workout
- [ ] Can view workout list
- [ ] Streak displays correctly
- [ ] Errors show user-friendly messages
- [ ] Works on iOS 17+

**Demo Preparation**:

- [ ] Create demo user account
- [ ] Prepare demo script
- [ ] Take screenshots
- [ ] Record screen demo (optional)
- [ ] Update PROJECT_STATUS.md

**Output**: MVP ready to demo

---

## MVP DELIVERABLES

### Functional Requirements ✅

1. User can register with email/password
2. User can login and receive JWT token
3. User can create a workout with name, type, duration
4. User can view list of their workouts
5. User can see current workout streak
6. iOS app connects to production backend
7. All user data is secure (passwords hashed, JWT tokens)

### Technical Requirements ✅

1. Backend deployed to Railway/Heroku
2. PostgreSQL database in production
3. HTTPS enabled
4. No secrets in Git repository
5. 80%+ test coverage
6. API documentation
7. iOS app builds and runs

### Documentation ✅

1. README with setup instructions
2. API endpoint documentation
3. Deployment guide
4. Test coverage report
5. Demo script

---

## TASK DISTRIBUTION SUMMARY

| Day | You (Backend Security) | Teammate 2 (Backend Features) | Teammate 3 (iOS) |

|-----|------------------------|-------------------------------|------------------|

| Mon | Fix .gitignore, rotate secrets, remove hardcoded fallbacks | Fix password leakage, add auth methods | Set up Xcode project, create structure |

| Tue | Password validation, remove console.logs | Polish workout endpoints, write tests | Create networking layer (APIService, AuthManager) |

| Wed | Test auth flow end-to-end | Add rate limiting | Build LoginView, RegisterView |

| Thu | Prepare deployment (Railway) | Write comprehensive tests | Build workout views (list, create) |

| Fri | Deploy to production | Run full test suite, fix bugs | Build HomeView/Dashboard |

| Sat | Review PRs, update docs | E2E tests, performance | Test on devices, fix UI bugs |

| Sun | Final backend verification | Final testing | Final iOS verification |

**Total Time**: ~25-30 hours per person over 7 days

---

## DAILY STANDUPS (15 minutes each morning)

**Format**:

1. What did you complete yesterday?
2. What will you work on today?
3. Any blockers?

**Communication**:

- Use Slack/Discord for quick questions
- Share code via GitHub PRs
- Test each other's work daily

---

## RISK MITIGATION

### If Backend Security Takes Longer

- Teammate 2 can help with validation logic
- Teammate 3 can work with mock data temporarily

### If iOS Development Falls Behind

- You can help with data models
- Teammate 2 can create sample JSON responses

### If Testing is Incomplete

- Focus on critical path testing only
- Document known issues for post-MVP

---

## SUCCESS CRITERIA

**Minimum Viable Product**:

- ✅ 1 user can register via iOS app
- ✅ User can login and stay logged in
- ✅ User can create 3 workouts
- ✅ User sees correct streak (3 days if daily)
- ✅ Backend is secure (no exposed secrets)
- ✅ App doesn't crash
- ✅ API responds in <2 seconds

**Demo-Ready**:

- ✅ Can show live demo without bugs
- ✅ Backend is accessible online
- ✅ iOS app works on your device
- ✅ Code is on GitHub with clean commits

---

## POST-MVP (Week 2+)

**Priorities after MVP**:

1. Add meal logging
2. Add health metrics calculations
3. Improve UI/UX polish
4. Add refresh tokens
5. Add session management
6. Comprehensive testing
7. App Store submission prep

**This gets you a working MVP in 1 week that demonstrates:**

- Full-stack development skills
- Security best practices
- Professional Git workflow
- Team collaboration
- Production deployment experience
- Mobile app development

You'll have a functional app to demo for your capstone!

### To-dos

- [ ] Update .gitignore and remove .env from Git tracking
- [ ] Generate new JWT secret and remove hardcoded fallbacks
- [ ] Fix password leakage in UserService with separate auth methods
- [ ] Set up Xcode project and basic structure
- [ ] Add password strength validation and remove console.logs
- [ ] Polish workout endpoints and write integration tests
- [ ] Create APIService, AuthManager, and KeychainManager
- [ ] Test full auth flow end-to-end
- [ ] Add rate limiting to auth endpoints
- [ ] Build LoginView and RegisterView
- [ ] Prepare backend for Railway deployment
- [ ] Write comprehensive workout test suite
- [ ] Build workout list and create views
- [ ] Deploy backend to Railway production
- [ ] Run full test suite and generate coverage report
- [ ] Create HomeView/Dashboard
- [ ] All team members: Fix bugs and polish features
- [ ] All team members: Final testing and demo preparation