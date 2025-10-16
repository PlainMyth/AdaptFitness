#  AdaptFitness - Complete Quick Start Guide

## Everything You Need to Know in One Place

---

##  Table of Contents

1. [Production API Access](#production-api-access)
2. [Local Development Setup](#local-development-setup)
3. [Testing the API](#testing-the-api)
4. [Authentication Flow](#authentication-flow)
5. [Using the API](#using-the-api)
6. [iOS Integration](#ios-integration)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

##  Production API Access

### **Live Production URL**
```
https://adaptfitness-production.up.railway.app
```

### **Quick Test (30 seconds)**
```bash
# Test the API is alive
curl https://adaptfitness-production.up.railway.app/health

# Register a user
curl -X POST https://adaptfitness-production.up.railway.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!@#","firstName":"Test","lastName":"User"}'

# Login and get JWT token
curl -X POST https://adaptfitness-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!@#"}'
```

### **What You Get:**
-  HTTPS enabled
-  Auto-deployed on git push
-  PostgreSQL database with backups
-  Professional infrastructure
-  All endpoints working

---

##  Local Development Setup

### **Prerequisites**
- Node.js 20+
- PostgreSQL 13+
- npm 10+

### **Quick Setup (5 minutes)**

```bash
# 1. Clone the repository
git clone https://github.com/AdaptFitness491/AdaptFitness.git
cd AdaptFitness/adaptfitness-backend

# 2. Install dependencies
npm install

# 3. Set up environment variables
cp env.example .env
# Edit .env with your values (see below)

# 4. Create PostgreSQL database
createdb adaptfitness

# 5. Start the development server
npm run start:dev
```

### **Environment Variables (.env file)**

**Minimum Required:**
```bash
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password_here
DATABASE_NAME=adaptfitness

# JWT (generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
JWT_SECRET=your_128_character_hex_secret_here
JWT_EXPIRES_IN=15m

# App
PORT=3000
NODE_ENV=development
```

### **Generate Secure JWT Secret:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### **Verify It Works:**
```bash
# API should be running on http://localhost:3000
curl http://localhost:3000/health
```

---

##  Testing the API

### **Automated Test Suite**

```bash
# Run all tests
npm test

# Run with coverage
npm run test:cov

# Run specific test file
npm test -- auth.service.spec.ts
```

### **E2E Testing Scripts**

```bash
# Test complete authentication flow (9 scenarios)
./test-auth-flow.sh

# Test rate limiting
./test-rate-limiting.sh

# Test production API
./test-production-complete.sh
```

### **Manual Testing**

```bash
# Health check
curl http://localhost:3000/health

# Register user
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!@#","firstName":"Test","lastName":"User"}'

# Login
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!@#"}'
```

---

##  Authentication Flow

### **Step-by-Step:**

**1. Register New User**
```bash
POST /auth/register
{
  "email": "user@example.com",
  "password": "SecurePass123!@#",
  "firstName": "John",
  "lastName": "Doe"
}

Response: HTTP 201
{
  "message": "User created successfully",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

**2. Login**
```bash
POST /auth/login
{
  "email": "user@example.com",
  "password": "SecurePass123!@#"
}

Response: HTTP 201
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

**3. Use JWT Token for Protected Endpoints**
```bash
GET /auth/profile
Headers: Authorization: Bearer <your_jwt_token>

Response: HTTP 200
{
  "id": "uuid",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "fullName": "John Doe",
  "isActive": true
}
```

### **Password Requirements:**
-  Minimum 8 characters
-  At least 1 uppercase letter
-  At least 1 lowercase letter
-  At least 1 number
-  At least 1 special character (!@#$%^&*...)

---

##  Using the API

### **Core Endpoints**

#### **Authentication** (No token required)
```bash
POST /auth/register     # Create account
POST /auth/login        # Get JWT token
```

#### **User Profile** (Token required)
```bash
GET  /auth/profile      # Get your profile
GET  /users/profile     # Get your profile (alternative)
PUT  /users/profile     # Update your profile
```

#### **Workouts** (Token required)
```bash
POST /workouts                  # Create workout
GET  /workouts                  # List your workouts
GET  /workouts/streak/current   # Get your current streak
GET  /workouts/:id              # Get workout details
PUT  /workouts/:id              # Update workout
DELETE /workouts/:id            # Delete workout
```

#### **Meals** (Token required)
```bash
POST /meals                     # Log meal
GET  /meals                     # List your meals
GET  /meals/streak/current      # Get meal logging streak
GET  /meals/:id                 # Get meal details
PUT  /meals/:id                 # Update meal
DELETE /meals/:id               # Delete meal
```

#### **Health Metrics** (Token required)
```bash
POST /health-metrics            # Create metrics entry
GET  /health-metrics            # List your metrics
GET  /health-metrics/latest     # Get latest metrics
GET  /health-metrics/calculations  # Get BMI, BMR, TDEE
PATCH /health-metrics/:id       # Update metrics
DELETE /health-metrics/:id      # Delete metrics
```

### **Example: Create Workout**

```bash
# 1. Get JWT token (from login)
TOKEN="your_jwt_token_here"

# 2. Create workout
curl -X POST http://localhost:3000/workouts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Morning Run",
    "description": "5K run in the park",
    "startTime": "2025-10-15T07:00:00Z",
    "totalCaloriesBurned": 300,
    "totalDuration": 30
  }'

# Response:
{
  "id": "uuid",
  "name": "Morning Run",
  "description": "5K run in the park",
  "startTime": "2025-10-15T07:00:00Z",
  "totalCaloriesBurned": 300,
  "totalDuration": 30,
  "userId": "your_user_id",
  "createdAt": "2025-10-15T07:05:00Z"
}
```

### **Example: Get Workout Streak**

```bash
curl -X GET http://localhost:3000/workouts/streak/current \
  -H "Authorization: Bearer $TOKEN"

# Response:
{
  "streak": 7,
  "lastWorkoutDate": "2025-10-15"
}
```

---

##  iOS Integration

### **Step 1: Create APIService.swift**

```swift
import Foundation

class APIService {
    static let shared = APIService()
    
    // PRODUCTION URL
    private let baseURL = "https://adaptfitness-production.up.railway.app"
    
    // OR use environment-based switching:
    private let baseURL: String = {
        #if DEBUG
        return "http://localhost:3000"
        #else
        return "https://adaptfitness-production.up.railway.app"
        #endif
    }()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // Generic request method
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add JWT token if required
        if requiresAuth, let token = UserDefaults.standard.string(forKey: "jwt_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
}
```

### **Step 2: Login from iOS**

```swift
// Login Request
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let access_token: String
    let user: User
}

// Usage:
func login(email: String, password: String) async throws {
    let response: LoginResponse = try await APIService.shared.request(
        endpoint: "/auth/login",
        method: "POST",
        body: LoginRequest(email: email, password: password),
        requiresAuth: false
    )
    
    // Store token
    UserDefaults.standard.set(response.access_token, forKey: "jwt_token")
    
    // Store user
    // ... update your app state
}
```

### **Step 3: Create Workout from iOS**

```swift
struct CreateWorkoutRequest: Encodable {
    let name: String
    let description: String?
    let startTime: String  // ISO8601 format
    let totalCaloriesBurned: Double?
    let totalDuration: Int?
}

// Usage:
func createWorkout() async throws {
    let workout = CreateWorkoutRequest(
        name: "Morning Run",
        description: "5K in the park",
        startTime: ISO8601DateFormatter().string(from: Date()),
        totalCaloriesBurned: 300,
        totalDuration: 30
    )
    
    let created: Workout = try await APIService.shared.request(
        endpoint: "/workouts",
        method: "POST",
        body: workout,
        requiresAuth: true
    )
    
    print("Workout created: \(created.id)")
}
```

---

##  Deployment

### **Deploy to Railway (15 minutes)**

**Prerequisites:**
- Railway account (free tier available)
- GitHub repository

**Quick Steps:**

1. **Create Railway Project**
   ```
   Go to railway.app → New Project → Deploy from GitHub
   Select your repository
   Set root directory: adaptfitness-backend
   ```

2. **Add PostgreSQL Database**
   ```
   In Railway project → Add Service → Database → PostgreSQL
   Railway auto-generates connection variables
   ```

3. **Set Environment Variables**
   ```
   Backend Service → Variables tab → Add these 11:
   
   DATABASE_HOST        (copy from Postgres PGHOST)
   DATABASE_PORT        (copy from Postgres PGPORT)
   DATABASE_USERNAME    (copy from Postgres PGUSER)
   DATABASE_PASSWORD    (copy from Postgres PGPASSWORD)
   DATABASE_NAME        (copy from Postgres PGDATABASE)
   TYPEORM_SYNCHRONIZE  (true for first deploy, then false)
   JWT_SECRET           (generate 128-char hex)
   JWT_EXPIRES_IN       (15m)
   NODE_ENV             (production)
   PORT                 (3000)
   CORS_ORIGIN          (*)
   ```

4. **Deploy & Test**
   ```bash
   # Railway auto-deploys on variable save
   # Wait 3-5 minutes
   
   # Test your deployment
   curl https://your-app.railway.app/health
   ```

5. **Lock Down Production**
   ```
   Change TYPEORM_SYNCHRONIZE from 'true' to 'false'
   Save → Auto-redeploy
   ```

**Full Guide:** See `RAILWAY_QUICK_START.md`

---

## 🎯 Common Use Cases

### **Use Case 1: New User Signs Up and Logs First Workout**

```bash
# 1. Register
curl -X POST https://adaptfitness-production.up.railway.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "MySecure123!@#",
    "firstName": "Jane",
    "lastName": "Smith"
  }'

# 2. Login
LOGIN_RESPONSE=$(curl -s -X POST https://adaptfitness-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"newuser@example.com","password":"MySecure123!@#"}')

# 3. Extract token
TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

# 4. Create workout
curl -X POST https://adaptfitness-production.up.railway.app/workouts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "First Workout",
    "description": "Getting started!",
    "startTime": "2025-10-15T08:00:00Z",
    "totalCaloriesBurned": 200,
    "totalDuration": 20
  }'

# 5. Check streak
curl -X GET https://adaptfitness-production.up.railway.app/workouts/streak/current \
  -H "Authorization: Bearer $TOKEN"
```

### **Use Case 2: Track Health Metrics**

```bash
# Create health metrics entry
curl -X POST https://adaptfitness-production.up.railway.app/health-metrics \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "currentWeight": 75.5,
    "bodyFatPercentage": 18.5,
    "goalWeight": 72
  }'

# Get calculations (BMI, BMR, TDEE)
curl -X GET https://adaptfitness-production.up.railway.app/health-metrics/calculations \
  -H "Authorization: Bearer $TOKEN"
```

---

##  Security Features

### **Password Security**
-  bcrypt hashing (12 salt rounds)
-  Strength validation enforced
-  Never returned in API responses
-  Separate auth methods prevent leakage

### **Authentication**
-  JWT tokens (15-minute expiration)
-  128-character secure secret
-  Bearer token authentication
-  All endpoints protected except auth

### **Rate Limiting**
-  **General endpoints:** 10 requests/minute
-  **Auth endpoints:** 5 requests/15 minutes
-  Prevents brute force attacks
-  HTTP 429 on limit exceeded

### **Input Validation**
-  class-validator decorators on all DTOs
-  Type checking and transformation
-  String length limits
-  Number range validation
-  Unknown properties rejected

---

##  API Endpoints Reference

### **Authentication (Public)**
```
POST /auth/register     - Create new user account
POST /auth/login        - Login and receive JWT token
```

### **User Management (Protected)**
```
GET  /auth/profile      - Get current user profile
GET  /users/profile     - Get user profile
PUT  /users/profile     - Update user profile
GET  /users/:id         - Get user by ID
DELETE /users/:id       - Delete user
```

### **Workouts (Protected)**
```
POST   /workouts                 - Create workout
GET    /workouts                 - List your workouts
GET    /workouts/streak/current  - Get current streak
GET    /workouts/:id             - Get workout details
PUT    /workouts/:id             - Update workout
DELETE /workouts/:id             - Delete workout
```

### **Meals (Protected)**
```
POST   /meals                    - Log meal
GET    /meals                    - List your meals
GET    /meals/streak/current     - Get meal logging streak
GET    /meals/:id                - Get meal details
PUT    /meals/:id                - Update meal
DELETE /meals/:id                - Delete meal
```

### **Health Metrics (Protected)**
```
POST   /health-metrics              - Create metrics entry
GET    /health-metrics              - List your metrics
GET    /health-metrics/latest       - Get latest metrics
GET    /health-metrics/calculations - Get BMI, BMR, TDEE
GET    /health-metrics/:id          - Get specific metrics
PATCH  /health-metrics/:id          - Update metrics
DELETE /health-metrics/:id          - Delete metrics
```

**See `README.md` for detailed request/response examples.**

---

##  Development Commands

```bash
# Development
npm run start:dev        # Start with hot-reload
npm run build            # Build TypeScript
npm run start:prod       # Start production build

# Testing
npm test                 # Run all tests
npm run test:watch       # Run tests in watch mode
npm run test:cov         # Generate coverage report
npm run test:e2e         # Run E2E tests

# Linting
npm run lint             # Run ESLint
npm run format           # Format with Prettier
```

---

##  Troubleshooting

### **Issue: "Missing required environment variables"**
**Fix:** Create `.env` file from `env.example` and fill in all values

### **Issue: "password authentication failed for user postgres"**
**Fix:** Update `DATABASE_PASSWORD` in `.env` with your PostgreSQL password

### **Issue: "secretOrPrivateKey must have a value"**
**Fix:** Generate JWT_SECRET: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`

### **Issue: "relation 'users' does not exist"**
**Fix:** Set `TYPEORM_SYNCHRONIZE=true` in Railway to create tables

### **Issue: HTTP 401 on protected endpoints**
**Fix:** Include `Authorization: Bearer <token>` header

### **Issue: HTTP 429 "Too Many Requests"**
**Fix:** Wait 1 minute (rate limit) or 15 minutes (auth rate limit)

### **Issue: Weak password rejected**
**Fix:** Use password with 8+ chars, uppercase, lowercase, number, special character

---

##  Additional Documentation

### **For Developers:**
- `README.md` - Full API documentation
- `CODE_DOCUMENTATION.md` - Architecture details
- `COMPLETE_VERIFICATION.md` - Development verification

### **For Deployment:**
- `DEPLOYMENT.md` - Comprehensive deployment guide
- `RAILWAY_QUICK_START.md` - 15-minute Railway setup
- `RAILWAY_ENV_SETUP.md` - Environment variables reference
- `RAILWAY_VARIABLES_QUICK_SETUP.md` - Quick checklist

### **For Testing:**
- `TESTING_AUTH.md` - Authentication testing
- `test-auth-flow.sh` - E2E auth tests
- `test-production-complete.sh` - Production test suite

### **For Integration:**
- `FRONTEND_INTEGRATION_ANALYSIS.md` - iOS integration guide
- `PRODUCTION_DEPLOYMENT_COMPLETE.md` - Production summary

---

##  Quick Commands Cheat Sheet

```bash
# LOCAL DEVELOPMENT
npm install                      # Install dependencies
npm run start:dev                # Start dev server
curl http://localhost:3000/health  # Test local API

# TESTING
npm test                         # Run all tests
./test-auth-flow.sh              # E2E auth test
./test-production-complete.sh    # Test production

# PRODUCTION
curl https://adaptfitness-production.up.railway.app/health  # Test production

# BUILD
npm run build                    # Build TypeScript
npm run start:prod               # Start production server
```

---

## 🎯 Success Checklist

**For Local Development:**
- [ ] PostgreSQL running locally
- [ ] `.env` file configured
- [ ] `npm install` completed
- [ ] `npm run start:dev` running
- [ ] Health endpoint returns 200

**For Production:**
- [ ] Railway account created
- [ ] PostgreSQL database added
- [ ] 11 environment variables set
- [ ] Backend deployed successfully
- [ ] All tests passing

**For iOS Integration:**
- [ ] APIService.swift created
- [ ] AuthManager.swift created
- [ ] Production URL configured
- [ ] Can register from iOS
- [ ] Can login from iOS
- [ ] Can create workouts from iOS

---

##  What You Have

### **Backend Features:**
-  Secure user authentication (JWT + bcrypt)
-  Workout tracking with automatic streak calculation
-  Meal logging with streak tracking
-  Health metrics with automatic calculations (BMI, BMR, TDEE)
-  Rate limiting & security
-  Professional error handling
-  Comprehensive testing (148 tests)
-  Complete API documentation

### **Infrastructure:**
-  Production deployment on Railway
-  PostgreSQL database with backups
-  HTTPS enabled
-  Auto-deploy on git push
-  Zero-downtime deployments
-  Environment-based configuration

### **Quality:**
-  85%+ test coverage
-  TypeScript strict mode
-  Professional code standards
-  Comprehensive documentation (16 files)
-  Production-ready infrastructure

---

##  You're Ready!

**Your backend is:**
-  **LIVE** in production
-  **SECURE** with enterprise-grade security
-  **TESTED** with comprehensive test suite
-  **DOCUMENTED** professionally
-  **READY** for iOS integration

**Production URL:** `https://adaptfitness-production.up.railway.app`

**Next Steps:**
1. Create iOS APIService.swift (copy from above)
2. Update iOS app to use production URL
3. Test login from iOS app
4. Start creating workouts from iOS
5. You'll have a full-stack fitness app! 

---

##  Pro Tips

**Testing:**
- Use the automated test scripts (`./test-*.sh`)
- Check coverage with `npm run test:cov`
- Test production regularly

**Security:**
- Never commit `.env` files
- Rotate secrets regularly
- Keep `TYPEORM_SYNCHRONIZE=false` in production
- Monitor rate limiting logs

**Performance:**
- Response times < 200ms (excellent)
- Database queries optimized with TypeORM
- Connection pooling enabled
- No N+1 query issues

**Debugging:**
- Check Railway logs for errors
- Use `curl -v` for verbose output
- Test with Postman for easier debugging
- Run local tests first before production

---

##  Support

**Documentation:**
- All guides in `adaptfitness-backend/*.md`
- API docs in `README.md`
- Examples in test scripts

**Testing:**
- Run `./test-production-complete.sh` to verify everything
- Check `TESTING_AUTH.md` for auth testing guide

**Issues:**
- Check Railway deployment logs
- Verify environment variables
- Run local tests to isolate issues

---

** You have everything you need to build a production fitness app!**

