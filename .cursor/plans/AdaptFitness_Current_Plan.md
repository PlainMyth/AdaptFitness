<!-- a816aab1-dd70-4c6d-a90b-94acca49a405 8f9a43f5-0ff9-42ad-8237-54d07be866a0 -->
# AdaptFitness Complete Development Plan

## Executive Summary

This plan outlines the complete development roadmap for AdaptFitness, a comprehensive fitness tracking application. It covers four critical domains: Security (protecting user data), Backend (API and business logic), Frontend (iOS app), and Network (deployment and infrastructure).

**Current Status**: Backend 70% complete with security vulnerabilities. iOS app is UI shell only. No production deployment.

**Timeline**: 8-12 weeks to production-ready MVP

---

## PHASE 1: CRITICAL SECURITY FIXES (Week 1 - 2-3 hours)

### 1.1 Git Security Remediation

**Problem**: `.env` file committed to Git history with exposed credentials

- Database password: `1234`
- JWT secret: `your-super-secret-jwt-key-change-in-production-adaptfitness-2024`
- Committed in: `80c6d7455302e81b365398cce5b46efdae8b0b0e`, `f0d2d18fa54d311955648dadd4cf1887c7e66ff4`

**Action Items**:

1. **Update `.gitignore`** (Root level: `/Users/.../AdaptFitness/.gitignore`)
   ```gitignore
   # Environment Files
   .env
   .env.local
   .env.*.local
   *.env
   
   # Backend
   adaptfitness-backend/node_modules/
   adaptfitness-backend/dist/
   adaptfitness-backend/coverage/
   adaptfitness-backend/.env
   adaptfitness-backend/npm-debug.log*
   
   # iOS
   adaptfitness-ios/DerivedData/
   adaptfitness-ios/build/
   adaptfitness-ios/*.xcworkspace
   adaptfitness-ios/*.xcuserdata
   
   # System
   .DS_Store
   .idea/
   .vscode/
   ```

2. **Remove `.env` from Git tracking**
   ```bash
   cd /Users/csuftitan/Downloads/AdaptFitness/AdaptFitness
   git rm --cached adaptfitness-backend/.env
   git commit -m "security: Remove .env from version control"
   ```

3. **Optional: Clean Git history** (Advanced - use with caution)
   ```bash
   # Install git-filter-repo
   brew install git-filter-repo
   
   # Remove .env from all commits
   git filter-repo --path adaptfitness-backend/.env --invert-paths
   
   # Force push (coordinate with team first!)
   git push origin --force --all
   ```


### 1.2 Rotate All Secrets

**Generate New Secrets**:

1. **JWT Secret** - Generate 128-character hex string
   ```bash
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```


Expected output: `a1b2c3d4...` (128 chars)

2. **Database Password** - If database is shared, update password
   ```bash
   # PostgreSQL command
   psql -U postgres
   ALTER USER postgres PASSWORD 'new_secure_password_here';
   ```


**Update Files**:

- `adaptfitness-backend/.env` - Update `JWT_SECRET` and `DATABASE_PASSWORD`
- `adaptfitness-backend/env.example` - Update comments with instructions

**env.example template**:

```bash
# SECURITY WARNING: Never commit this file to Git!
# Copy this file to .env and update with your actual values

# Database Configuration
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=GENERATE_SECURE_PASSWORD_HERE
DATABASE_NAME=adaptfitness

# JWT Configuration - CRITICAL: Generate with crypto.randomBytes(64).toString('hex')
JWT_SECRET=GENERATE_128_CHAR_HEX_STRING_HERE
JWT_EXPIRES_IN=15m

# JWT Refresh Token
JWT_REFRESH_SECRET=GENERATE_DIFFERENT_128_CHAR_HEX_STRING_HERE
JWT_REFRESH_EXPIRES_IN=7d

# Application
PORT=3000
NODE_ENV=development

# CORS - Update for production
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
```

### 1.3 Remove Hardcoded Secret Fallbacks

**Files to Modify**:

**File 1**: `adaptfitness-backend/src/app.module.ts` (line 58)

```typescript
// BEFORE:
secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production-adaptfitness-2024',

// AFTER:
secret: process.env.JWT_SECRET,
```

**File 2**: `adaptfitness-backend/src/auth/auth.module.ts` (line 23)

```typescript
// BEFORE:
secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production-adaptfitness-2024',

// AFTER:
secret: process.env.JWT_SECRET,
```

**File 3**: `adaptfitness-backend/src/auth/strategies/jwt.strategy.ts` (line 31)

```typescript
// BEFORE:
secretOrKey: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production-adaptfitness-2024',

// AFTER:
secretOrKey: process.env.JWT_SECRET,
```

### 1.4 Add Environment Validation

**Create New File**: `adaptfitness-backend/src/config/env.validation.ts`

```typescript
export function validateEnvironment(): void {
  const required = [
    'DATABASE_HOST',
    'DATABASE_PORT',
    'DATABASE_USERNAME',
    'DATABASE_PASSWORD',
    'DATABASE_NAME',
    'JWT_SECRET',
    'JWT_EXPIRES_IN',
  ];

  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}\n` +
      'Please create a .env file based on env.example'
    );
  }

  // Validate JWT secret strength
  if (process.env.JWT_SECRET.length < 64) {
    throw new Error('JWT_SECRET must be at least 64 characters long');
  }
}
```

**Update**: `adaptfitness-backend/src/main.ts` (add at top of bootstrap function)

```typescript
import { validateEnvironment } from './config/env.validation';

async function bootstrap() {
  // Validate environment before starting
  validateEnvironment();
  
  // ... rest of bootstrap code
}
```

### 1.5 Fix Password Leakage in Database Queries

**Problem**: `findByEmail()` and `findById()` return password hash

**File**: `adaptfitness-backend/src/user/user.service.ts`

**Solution**: Create separate methods for auth vs general use

```typescript
// FOR AUTHENTICATION ONLY - includes password
async findByEmailForAuth(email: string): Promise<User | undefined> {
  return this.userRepository.findOne({ where: { email } });
}

// FOR GENERAL USE - excludes password
async findByEmail(email: string): Promise<User | undefined> {
  return this.userRepository.findOne({ 
    where: { email },
    select: ['id', 'email', 'firstName', 'lastName', 'dateOfBirth', 'height', 'weight', 'gender', 'activityLevel', 'activityLevelMultiplier', 'isActive', 'createdAt', 'updatedAt']
  });
}

// FOR AUTHENTICATION ONLY - includes password
async findByIdForAuth(id: string): Promise<User | undefined> {
  return this.userRepository.findOne({ where: { id } });
}

// FOR GENERAL USE - excludes password
async findById(id: string): Promise<User | undefined> {
  return this.userRepository.findOne({ 
    where: { id },
    select: ['id', 'email', 'firstName', 'lastName', 'dateOfBirth', 'height', 'weight', 'gender', 'activityLevel', 'activityLevelMultiplier', 'isActive', 'createdAt', 'updatedAt']
  });
}
```

**Update Auth Service**: `adaptfitness-backend/src/auth/auth.service.ts`

```typescript
async validateUser(email: string, password: string): Promise<any> {
  // Use ForAuth method to get password
  const user = await this.userService.findByEmailForAuth(email);
  // ... rest of method
}
```

**Update JWT Strategy**: `adaptfitness-backend/src/auth/strategies/jwt.strategy.ts`

```typescript
async validate(payload: JwtPayload) {
  // Use ForAuth method
  const user = await this.userService.findByIdForAuth(payload.sub);
  // ... rest of method
}
```

### 1.6 Remove Sensitive Logging

**File**: `adaptfitness-backend/src/auth/strategies/jwt.strategy.ts`

**Remove/Guard These Lines**:

```typescript
// DELETE THESE:
console.log('🔐 JWT Strategy validate called with payload:', payload); // Line 36 - exposes JWT
console.log('❌ User not found for ID:', payload.sub); // Line 40 - exposes user ID
console.log('❌ User is inactive:', user.email); // Line 44 - exposes email
console.log('✅ User validated successfully:', user.email); // Line 47 - exposes email
console.log('❌ JWT validation error:', error.message); // Line 50 - might expose sensitive info
```

**Replace with environment-guarded logging** (optional):

```typescript
if (process.env.NODE_ENV === 'development') {
  console.log('JWT validation attempt'); // Generic, no sensitive data
}
```

---

## PHASE 2: BACKEND SECURITY ENHANCEMENTS (Week 1-2 - 6-8 hours)

### 2.1 Rate Limiting

**Purpose**: Prevent brute force attacks on authentication

**Install Dependencies**:

```bash
cd adaptfitness-backend
npm install --save @nestjs/throttler
```

**Create Config File**: `adaptfitness-backend/src/config/throttler.config.ts`

```typescript
import { ThrottlerModuleOptions } from '@nestjs/throttler';

export const throttlerConfig: ThrottlerModuleOptions = {
  ttl: 60, // Time window in seconds
  limit: 10, // Max requests per ttl
};

export const authThrottlerConfig = {
  ttl: 900, // 15 minutes
  limit: 5, // 5 attempts per 15 minutes
};
```

**Update App Module**: `adaptfitness-backend/src/app.module.ts`

```typescript
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { throttlerConfig } from './config/throttler.config';

@Module({
  imports: [
    // ... existing imports
    ThrottlerModule.forRoot(throttlerConfig),
  ],
  providers: [
    // ... existing providers
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard, // Apply globally
    },
  ],
})
```

**Update Auth Controller**: `adaptfitness-backend/src/auth/auth.controller.ts`

```typescript
import { Throttle } from '@nestjs/throttler';
import { authThrottlerConfig } from '../config/throttler.config';

@Controller('auth')
export class AuthController {
  
  @Post('register')
  @Throttle(authThrottlerConfig.limit, authThrottlerConfig.ttl)
  async register(@Body() registerDto: RegisterDto) {
    // ... existing code
  }

  @Post('login')
  @Throttle(authThrottlerConfig.limit, authThrottlerConfig.ttl)
  async login(@Body() loginDto: LoginDto) {
    // ... existing code
  }
}
```

### 2.2 Password Strength Validation

**Create Validator**: `adaptfitness-backend/src/auth/validators/password.validator.ts`

```typescript
export class PasswordValidator {
  private static readonly MIN_LENGTH = 8;
  private static readonly REGEX = {
    uppercase: /[A-Z]/,
    lowercase: /[a-z]/,
    number: /[0-9]/,
    special: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/,
  };

  static validate(password: string): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (password.length < this.MIN_LENGTH) {
      errors.push(`Password must be at least ${this.MIN_LENGTH} characters long`);
    }

    if (!this.REGEX.uppercase.test(password)) {
      errors.push('Password must contain at least one uppercase letter');
    }

    if (!this.REGEX.lowercase.test(password)) {
      errors.push('Password must contain at least one lowercase letter');
    }

    if (!this.REGEX.number.test(password)) {
      errors.push('Password must contain at least one number');
    }

    if (!this.REGEX.special.test(password)) {
      errors.push('Password must contain at least one special character');
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }
}
```

**Update Auth Service**: `adaptfitness-backend/src/auth/auth.service.ts`

```typescript
import { PasswordValidator } from './validators/password.validator';

async register(registerDto: RegisterDto): Promise<RegisterResponseDto> {
  // Validate password strength
  const validation = PasswordValidator.validate(registerDto.password);
  if (!validation.valid) {
    throw new BadRequestException({
      message: 'Password does not meet requirements',
      errors: validation.errors,
    });
  }

  // ... rest of registration logic
}
```

### 2.3 Account Lockout Mechanism

**Update User Entity**: `adaptfitness-backend/src/user/user.entity.ts`

```typescript
@Entity('users')
export class User {
  // ... existing fields

  @Column({ default: 0 })
  failedLoginAttempts: number;

  @Column({ nullable: true })
  lockedUntil: Date;

  // Helper method
  get isLocked(): boolean {
    if (!this.lockedUntil) return false;
    return new Date() < this.lockedUntil;
  }
}
```

**Update Auth Service**: `adaptfitness-backend/src/auth/auth.service.ts`

```typescript
async login(loginDto: LoginDto): Promise<AuthResponseDto> {
  const user = await this.userService.findByEmailForAuth(loginDto.email);

  if (!user) {
    throw new UnauthorizedException('Invalid credentials');
  }

  // Check if account is locked
  if (user.isLocked) {
    const minutesLeft = Math.ceil((user.lockedUntil.getTime() - Date.now()) / 60000);
    throw new UnauthorizedException(
      `Account locked due to too many failed attempts. Try again in ${minutesLeft} minutes`
    );
  }

  // Validate password
  const isValid = await bcrypt.compare(loginDto.password, user.password);

  if (!isValid) {
    // Increment failed attempts
    user.failedLoginAttempts += 1;

    // Lock account after 5 failed attempts
    if (user.failedLoginAttempts >= 5) {
      user.lockedUntil = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
      await this.userService.update(user.id, { 
        failedLoginAttempts: user.failedLoginAttempts,
        lockedUntil: user.lockedUntil 
      });
      throw new UnauthorizedException('Account locked due to too many failed attempts');
    }

    await this.userService.update(user.id, { 
      failedLoginAttempts: user.failedLoginAttempts 
    });
    throw new UnauthorizedException('Invalid credentials');
  }

  // Reset failed attempts on successful login
  if (user.failedLoginAttempts > 0) {
    await this.userService.update(user.id, { 
      failedLoginAttempts: 0,
      lockedUntil: null 
    });
  }

  // ... generate JWT and return
}
```

### 2.4 Production Logging System

**Install Winston**:

```bash
npm install --save nest-winston winston
```

**Create Logger Module**: `adaptfitness-backend/src/logger/logger.module.ts`

```typescript
import { Module } from '@nestjs/common';
import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json(),
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

// Add console transport in development
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

@Module({
  imports: [
    WinstonModule.forRoot({
      instance: logger,
    }),
  ],
  exports: [WinstonModule],
})
export class LoggerModule {}
```

**Usage in Services**:

```typescript
import { Inject, Injectable } from '@nestjs/common';
import { WINSTON_MODULE_PROVIDER } from 'nest-winston';
import { Logger } from 'winston';

@Injectable()
export class AuthService {
  constructor(
    @Inject(WINSTON_MODULE_PROVIDER) private readonly logger: Logger,
  ) {}

  async login(loginDto: LoginDto) {
    this.logger.info('Login attempt', { email: loginDto.email }); // Safe - no password
    // ... rest of login logic
  }
}
```

---

## PHASE 3: BACKEND COMPLETION (Week 2-4 - 20-30 hours)

### 3.1 JWT Refresh Token System

**Purpose**: Short-lived access tokens (15min) + long-lived refresh tokens (7 days)

**Create Refresh Token Entity**: `adaptfitness-backend/src/auth/entities/refresh-token.entity.ts`

```typescript
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from '../../user/user.entity';

@Entity('refresh_tokens')
export class RefreshToken {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  token: string;

  @ManyToOne(() => User)
  user: User;

  @Column()
  userId: string;

  @Column()
  expiresAt: Date;

  @Column({ default: false })
  revoked: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @Column({ nullable: true })
  revokedAt: Date;

  get isExpired(): boolean {
    return new Date() > this.expiresAt;
  }

  get isValid(): boolean {
    return !this.revoked && !this.isExpired;
  }
}
```

**Update Auth Service**:

```typescript
async login(loginDto: LoginDto): Promise<AuthResponseDto> {
  // ... existing validation

  // Generate access token (15 minutes)
  const accessToken = this.jwtService.sign(
    { email: user.email, sub: user.id },
    { expiresIn: '15m' }
  );

  // Generate refresh token (7 days)
  const refreshToken = this.jwtService.sign(
    { email: user.email, sub: user.id, type: 'refresh' },
    { expiresIn: '7d', secret: process.env.JWT_REFRESH_SECRET }
  );

  // Store refresh token in database
  await this.storeRefreshToken(user.id, refreshToken);

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_in: 900, // 15 minutes in seconds
    user: { /* user data */ },
  };
}

private async storeRefreshToken(userId: string, token: string) {
  const refreshToken = this.refreshTokenRepository.create({
    userId,
    token,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
  });
  await this.refreshTokenRepository.save(refreshToken);
}
```

**Add Refresh Endpoint**: `adaptfitness-backend/src/auth/auth.controller.ts`

```typescript
@Post('refresh')
async refresh(@Body('refresh_token') refreshToken: string): Promise<AuthResponseDto> {
  return this.authService.refreshAccessToken(refreshToken);
}
```

### 3.2 Session Management

**Create Session Entity**: `adaptfitness-backend/src/auth/entities/session.entity.ts`

```typescript
@Entity('sessions')
export class Session {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User)
  user: User;

  @Column()
  userId: string;

  @Column()
  deviceInfo: string; // User agent

  @Column()
  ipAddress: string;

  @Column()
  lastActivityAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @Column({ default: false })
  revoked: boolean;
}
```

**Add Session Endpoints**:

```typescript
@Controller('auth')
export class AuthController {
  
  @Get('sessions')
  @UseGuards(JwtAuthGuard)
  async getSessions(@Request() req) {
    return this.authService.getUserSessions(req.user.id);
  }

  @Delete('sessions/:id')
  @UseGuards(JwtAuthGuard)
  async revokeSession(@Request() req, @Param('id') sessionId: string) {
    return this.authService.revokeSession(req.user.id, sessionId);
  }

  @Post('logout-all')
  @UseGuards(JwtAuthGuard)
  async logoutAll(@Request() req) {
    return this.authService.revokeAllSessions(req.user.id);
  }
}
```

### 3.3 Security Headers & HTTPS

**Install Helmet**:

```bash
npm install --save helmet
```

**Update Main.ts**: `adaptfitness-backend/src/main.ts`

```typescript
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security headers
  app.use(helmet());

  // HTTPS enforcement in production
  if (process.env.NODE_ENV === 'production') {
    app.use((req, res, next) => {
      if (req.header('x-forwarded-proto') !== 'https') {
        res.redirect(301, `https://${req.header('host')}${req.url}`);
      } else {
        next();
      }
    });
  }

  // CORS - require explicit configuration
  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(',') || [],
    credentials: true,
  });

  // ... rest of bootstrap
}
```

### 3.4 Input Sanitization & Validation

**Install Dependencies**:

```bash
npm install --save class-validator class-transformer
npm install --save-dev @types/validator
```

**Update Global Validation Pipe**: `adaptfitness-backend/src/main.ts`

```typescript
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true, // Strip unknown properties
    forbidNonWhitelisted: true, // Throw error on unknown properties
    transform: true, // Auto-transform to DTO types
    transformOptions: {
      enableImplicitConversion: true,
    },
    disableErrorMessages: process.env.NODE_ENV === 'production', // Hide detailed errors in prod
  }),
);
```

---

## PHASE 4: iOS FRONTEND DEVELOPMENT (Week 3-8 - 60-80 hours)

### 4.1 Project Setup & Architecture

**Create iOS App Structure**:

```
adaptfitness-ios/
├── AdaptFitness/
│   ├── App/
│   │   └── AdaptFitnessApp.swift
│   ├── Core/
│   │   ├── Network/
│   │   │   ├── APIService.swift
│   │   │   ├── NetworkError.swift
│   │   │   └── Endpoints.swift
│   │   ├── Auth/
│   │   │   ├── AuthManager.swift
│   │   │   ├── KeychainManager.swift
│   │   │   └── AuthState.swift
│   │   └── Storage/
│   │       └── UserDefaultsManager.swift
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Workout.swift
│   │   ├── Meal.swift
│   │   ├── HealthMetrics.swift
│   │   └── APIResponse.swift
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── WorkoutViewModel.swift
│   │   ├── MealViewModel.swift
│   │   └── HealthMetricsViewModel.swift
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   └── RegisterView.swift
│   │   ├── Home/
│   │   │   └── HomeView.swift
│   │   ├── Workouts/
│   │   │   ├── WorkoutListView.swift
│   │   │   ├── WorkoutDetailView.swift
│   │   │   └── CreateWorkoutView.swift
│   │   ├── Meals/
│   │   │   ├── MealListView.swift
│   │   │   ├── MealDetailView.swift
│   │   │   └── CreateMealView.swift
│   │   └── Profile/
│   │       └── ProfileView.swift
│   └── Utils/
│       ├── Extensions/
│       └── Constants.swift
```

### 4.2 Core Networking Layer

**File**: `adaptfitness-ios/AdaptFitness/Core/Network/APIService.swift`

```swift
import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000" // Update for production
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    // Generic request method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add JWT token if required
        if requiresAuth, let token = AuthManager.shared.accessToken {
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
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            // Token expired - try refresh
            try await AuthManager.shared.refreshToken()
            // Retry request
            return try await self.request(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
```

**File**: `adaptfitness-ios/AdaptFitness/Core/Network/NetworkError.swift`

```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case rateLimited
    case unauthorized
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .unauthorized:
            return "Please log in again"
        case .noConnection:
            return "No internet connection"
        }
    }
}
```

### 4.3 Authentication Manager

**File**: `adaptfitness-ios/AdaptFitness/Core/Auth/AuthManager.swift`

```swift
import Foundation
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private(set) var accessToken: String?
    private var refreshToken: String?
    
    private let keychain = KeychainManager.shared
    
    private init() {
        loadTokens()
    }
    
    func login(email: String, password: String) async throws {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        struct LoginResponse: Decodable {
            let access_token: String
            let refresh_token: String
            let user: User
        }
        
        let response: LoginResponse = try await APIService.shared.request(
            endpoint: "/auth/login",
            method: .post,
            body: LoginRequest(email: email, password: password),
            requiresAuth: false
        )
        
        // Store tokens securely
        accessToken = response.access_token
        refreshToken = response.refresh_token
        try keychain.save(accessToken!, forKey: "accessToken")
        try keychain.save(refreshToken!, forKey: "refreshToken")
        
        currentUser = response.user
        isAuthenticated = true
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        struct RegisterRequest: Encodable {
            let email: String
            let password: String
            let firstName: String
            let lastName: String
        }
        
        struct RegisterResponse: Decodable {
            let message: String
            let user: User
        }
        
        let _: RegisterResponse = try await APIService.shared.request(
            endpoint: "/auth/register",
            method: .post,
            body: RegisterRequest(email: email, password: password, firstName: firstName, lastName: lastName),
            requiresAuth: false
        )
        
        // After registration, login
        try await login(email: email, password: password)
    }
    
    func refreshToken() async throws {
        guard let refreshToken = refreshToken else {
            throw NetworkError.unauthorized
        }
        
        struct RefreshRequest: Encodable {
            let refresh_token: String
        }
        
        struct RefreshResponse: Decodable {
            let access_token: String
            let refresh_token: String
        }
        
        let response: RefreshResponse = try await APIService.shared.request(
            endpoint: "/auth/refresh",
            method: .post,
            body: RefreshRequest(refresh_token: refreshToken),
            requiresAuth: false
        )
        
        accessToken = response.access_token
        self.refreshToken = response.refresh_token
        try keychain.save(accessToken!, forKey: "accessToken")
        try keychain.save(response.refresh_token, forKey: "refreshToken")
    }
    
    func logout() {
        accessToken = nil
        refreshToken = nil
        currentUser = nil
        isAuthenticated = false
        
        keychain.delete(forKey: "accessToken")
        keychain.delete(forKey: "refreshToken")
    }
    
    private func loadTokens() {
        accessToken = keychain.load(forKey: "accessToken")
        refreshToken = keychain.load(forKey: "refreshToken")
        isAuthenticated = accessToken != nil
        
        if isAuthenticated {
            Task {
                try? await loadCurrentUser()
            }
        }
    }
    
    private func loadCurrentUser() async throws {
        currentUser = try await APIService.shared.request(endpoint: "/auth/profile", method: .get)
    }
}
```

**File**: `adaptfitness-ios/AdaptFitness/Core/Auth/KeychainManager.swift`

```swift
import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    func save(_ value: String, forKey key: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case saveFailed
}
```

### 4.4 Data Models

**File**: `adaptfitness-ios/AdaptFitness/Models/User.swift`

```swift
import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let dateOfBirth: Date?
    let height: Double?
    let weight: Double?
    let gender: String?
    let activityLevel: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
```

**File**: `adaptfitness-ios/AdaptFitness/Models/Workout.swift`

```swift
import Foundation

struct Workout: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let startTime: Date
    let endTime: Date?
    let totalCaloriesBurned: Double?
    let totalDuration: Int?
    let totalSets: Int?
    let totalReps: Int?
    let totalWeight: Double?
    let workoutType: WorkoutType
    let isCompleted: Bool
    let userId: String
    let createdAt: Date
    let updatedAt: Date
}

enum WorkoutType: String, Codable, CaseIterable {
    case cardio
    case strength
    case flexibility
    case sports
    case other
}
```

### 4.5 ViewModels (MVVM Pattern)

**File**: `adaptfitness-ios/AdaptFitness/ViewModels/WorkoutViewModel.swift`

```swift
import Foundation

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var currentStreak: Int = 0
    @Published var isLoading = false
    @Published var error: NetworkError?
    
    func loadWorkouts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            workouts = try await APIService.shared.request(
                endpoint: "/workouts",
                method: .get
            )
        } catch let error as NetworkError {
            self.error = error
        } catch {
            self.error = .invalidResponse
        }
    }
    
    func loadCurrentStreak() async {
        do {
            struct StreakResponse: Decodable {
                let streak: Int
            }
            
            let response: StreakResponse = try await APIService.shared.request(
                endpoint: "/workouts/streak/current",
                method: .get
            )
            currentStreak = response.streak
        } catch {
            // Handle error silently for streak
        }
    }
    
    func createWorkout(_ workout: Workout) async throws {
        let created: Workout = try await APIService.shared.request(
            endpoint: "/workouts",
            method: .post,
            body: workout
        )
        workouts.insert(created, at: 0)
    }
    
    func deleteWorkout(id: String) async throws {
        let _: EmptyResponse = try await APIService.shared.request(
            endpoint: "/workouts/\(id)",
            method: .delete
        )
        workouts.removeAll { $0.id == id }
    }
}

struct EmptyResponse: Decodable {}
```

### 4.6 Views (SwiftUI)

**File**: `adaptfitness-ios/AdaptFitness/Views/Auth/LoginView.swift`

```swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "figure.run")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("AdaptFitness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                NavigationLink("Don't have an account? Sign Up", destination: RegisterView())
                    .font(.footnote)
            }
            .padding()
            .navigationTitle("Welcome Back")
        }
    }
    
    private func login() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}
```

**File**: `adaptfitness-ios/AdaptFitness/Views/Workouts/WorkoutListView.swift`

```swift
import SwiftUI

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showingCreateSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.workouts.isEmpty {
                    VStack {
                        Image(systemName: "figure.run.square.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No workouts yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap + to create your first workout")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        Section {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("Current Streak:")
                                Spacer()
                                Text("\(viewModel.currentStreak) days")
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Section("Recent Workouts") {
                            ForEach(viewModel.workouts) { workout in
                                WorkoutRow(workout: workout)
                            }
                            .onDelete(perform: deleteWorkout)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateWorkoutView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadWorkouts()
                await viewModel.loadCurrentStreak()
            }
        }
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        for index in offsets {
            let workout = viewModel.workouts[index]
            Task {
                try? await viewModel.deleteWorkout(id: workout.id)
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.name)
                .font(.headline)
            HStack {
                Text(workout.workoutType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.gray)
                if let calories = workout.totalCaloriesBurned {
                    Text("•")
                        .foregroundColor(.gray)
                    Text("\(Int(calories)) cal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                if let duration = workout.totalDuration {
                    Text("•")
                        .foregroundColor(.gray)
                    Text("\(duration) min")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

---

## PHASE 5: NETWORK & DEPLOYMENT (Week 7-8 - 10-15 hours)

### 5.1 Backend Deployment (Heroku/Railway/DigitalOcean)

**Option A: Railway (Recommended for simplicity)**

**Prepare Backend**:

1. Create `Procfile` in `adaptfitness-backend/`:
   ```
   web: npm run start:prod
   ```

2. Update `package.json`:
   ```json
   {
     "engines": {
       "node": ">=20.0.0",
       "npm": ">=10.0.0"
     }
   }
   ```

3. Create `railway.json`:
   ```json
   {
     "build": {
       "builder": "NIXPACKS"
     },
     "deploy": {
       "numReplicas": 1,
       "sleepApplication": false,
       "restartPolicyType": "ON_FAILURE",
       "restartPolicyMaxRetries": 10
     }
   }
   ```


**Deploy Steps**:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize project
cd adaptfitness-backend
railway init

# Add environment variables (via Railway dashboard)
# DATABASE_URL, JWT_SECRET, etc.

# Deploy
railway up
```

**Set Environment Variables in Railway Dashboard**:

- `DATABASE_HOST` - Railway PostgreSQL host
- `DATABASE_PORT` - 5432
- `DATABASE_USERNAME` - Railway DB user
- `DATABASE_PASSWORD` - Railway DB password
- `DATABASE_NAME` - Railway DB name
- `JWT_SECRET` - Your generated 128-char secret
- `JWT_REFRESH_SECRET` - Different 128-char secret
- `NODE_ENV` - production
- `CORS_ORIGIN` - Your iOS app domain (if web) or * for mobile
- `PORT` - (Railway sets automatically)

### 5.2 Database Setup (Production PostgreSQL)

**Railway PostgreSQL**:

1. Add PostgreSQL plugin in Railway dashboard
2. Railway auto-generates `DATABASE_URL`
3. Backend automatically connects using env vars

**Run Migrations**:

```bash
# TypeORM will auto-sync schema on first run (synchronize: true in dev)
# For production, create migrations:
cd adaptfitness-backend
npm run typeorm migration:generate -- -n InitialSchema
npm run typeorm migration:run
```

**Set `synchronize: false` in production**: `app.module.ts`

```typescript
synchronize: process.env.NODE_ENV !== 'production', // Already done
```

### 5.3 API Configuration for iOS

**Update iOS Constants**: `adaptfitness-ios/AdaptFitness/Utils/Constants.swift`

```swift
struct APIConstants {
    #if DEBUG
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "https://your-app.railway.app" // Update with your Railway URL
    #endif
    
    static let timeout: TimeInterval = 30
}
```

**Update APIService**:

```swift
class APIService {
    private let baseURL = APIConstants.baseURL
    // ... rest of implementation
}
```

### 5.4 SSL/TLS Configuration

**Railway**: Automatically provides HTTPS with Let's Encrypt certificates

**Custom Domain** (Optional):

1. Purchase domain (Namecheap, Google Domains)
2. Add custom domain in Railway dashboard
3. Update DNS records (CNAME to Railway)
4. Update `CORS_ORIGIN` and iOS `baseURL`

### 5.5 Monitoring & Logging

**Add Sentry for Error Tracking**:

```bash
cd adaptfitness-backend
npm install --save @sentry/node
```

**Configure Sentry**: `main.ts`

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

**Add Health Check Endpoint** (Already exists: `/health`)

**Set Up Uptime Monitoring**:

- Use Railway's built-in monitoring
- Or UptimeRobot (free)
- Ping `/health` every 5 minutes

---

## PHASE 6: TESTING & QA (Week 8 - 10-15 hours)

### 6.1 Backend Testing

**Unit Tests** (Already partially implemented):

```bash
cd adaptfitness-backend
npm test
```

**Integration Tests**: Create `test/integration/` folder

- Test auth flow (register → login → protected endpoint)
- Test workout CRUD operations
- Test meal CRUD operations
- Test health metrics calculations

**E2E Tests**: Create `test/e2e/` folder

```typescript
// test/e2e/auth.e2e-spec.ts
describe('Authentication (e2e)', () => {
  it('should register a new user', () => {
    return request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: 'test@example.com', password: 'Test123!@#' })
      .expect(201);
  });
});
```

**Load Testing**: Use Artillery or K6

```bash
npm install -g artillery
artillery quick --count 100 --num 10 https://your-api.railway.app/health
```

### 6.2 iOS Testing

**Unit Tests**: Create `AdaptFitnessTests/` folder

- Test ViewModels (WorkoutViewModel, MealViewModel)
- Test APIService
- Test AuthManager

**UI Tests**: Create `AdaptFitnessUITests/` folder

```swift
func testLoginFlow() {
    let app = XCUIApplication()
    app.launch()
    
    app.textFields["Email"].tap()
    app.textFields["Email"].typeText("test@example.com")
    
    app.secureTextFields["Password"].tap()
    app.secureTextFields["Password"].typeText("Test123!@#")
    
    app.buttons["Log In"].tap()
    
    XCTAssertTrue(app.navigationBars["Dashboard"].exists)
}
```

### 6.3 Security Testing

**OWASP Top 10 Checklist**:

- [ ] SQL Injection - TypeORM prevents (ORM-based)
- [ ] Authentication Broken - JWT with refresh tokens
- [ ] Sensitive Data Exposure - Passwords hashed, HTTPS enforced
- [ ] XML External Entities - N/A (JSON API)
- [ ] Broken Access Control - User ownership validation on all endpoints
- [ ] Security Misconfiguration - Helmet, CORS, env validation
- [ ] XSS - N/A (API only, iOS handles rendering)
- [ ] Insecure Deserialization - Input validation with class-validator
- [ ] Using Components with Known Vulnerabilities - Run `npm audit`
- [ ] Insufficient Logging - Winston logging implemented

**Run Security Audit**:

```bash
cd adaptfitness-backend
npm audit
npm audit fix
```

---

## PHASE 7: DEPLOYMENT & LAUNCH (Week 8)

### 7.1 Backend Production Checklist

- [ ] All environment variables set in Railway
- [ ] `synchronize: false` in production
- [ ] Error logging with Sentry configured
- [ ] Rate limiting enabled
- [ ] Helmet middleware active
- [ ] CORS restricted to production domains
- [ ] HTTPS enforced
- [ ] Database backups configured (Railway automatic)
- [ ] Health check endpoint working
- [ ] All tests passing

### 7.2 iOS App Store Preparation

**App Store Connect Setup**:

1. Create App ID in Apple Developer Portal
2. Create app in App Store Connect
3. Configure app metadata (name, description, screenshots)
4. Set up TestFlight for beta testing

**Update App Configuration**:

- Set proper bundle identifier
- Configure app icons and launch screen
- Add privacy policy URL
- Configure required permissions (camera for meal scanning, etc.)

**Build for TestFlight**:

```bash
# Xcode
Product → Archive → Distribute App → App Store Connect
```

### 7.3 iOS Deployment Checklist

- [ ] Production API URL configured
- [ ] All API endpoints tested against production
- [ ] Error handling for all network requests
- [ ] Offline mode graceful degradation
- [ ] Loading states on all async operations
- [ ] Proper error messages for users
- [ ] App icons and splash screen configured
- [ ] Privacy policy and terms of service
- [ ] TestFlight beta testing completed

---

## TIMELINE SUMMARY

| Week | Phase | Focus | Hours |

|------|-------|-------|-------|

| 1 | Phase 1 | Critical Security Fixes | 2-3 |

| 1-2 | Phase 2 | Backend Security Enhancements | 6-8 |

| 2-4 | Phase 3 | Backend Completion | 20-30 |

| 3-8 | Phase 4 | iOS Frontend Development | 60-80 |

| 7-8 | Phase 5 | Network & Deployment | 10-15 |

| 8 | Phase 6 | Testing & QA | 10-15 |

| 8 | Phase 7 | Deployment & Launch | 5-10 |

| **Total** | | | **113-161 hours** |

---

## PRIORITY RECOMMENDATIONS

**Do These IMMEDIATELY** (This Week):

1. Fix `.gitignore` and remove `.env` from Git
2. Rotate JWT secret and database password
3. Remove hardcoded secret fallbacks
4. Fix password leakage in UserService
5. Remove console.log statements with user data

**Do These BEFORE iOS Development** (Next Week):

1. Add rate limiting
2. Add password strength validation
3. Implement account lockout
4. Set up proper logging (Winston)
5. Add JWT refresh token system

**Do These BEFORE Production** (Before Launch):

1. Security headers (Helmet)
2. HTTPS enforcement
3. Session management
4. Deploy to Railway/Heroku
5. Complete iOS app features

---

## SUCCESS CRITERIA

**Backend Ready for Production**:

- ✅ No security vulnerabilities
- ✅ All endpoints authenticated
- ✅ Rate limiting active
- ✅ Proper error handling
- ✅ 90%+ test coverage
- ✅ Deployed with HTTPS
- ✅ Database backups configured

**iOS App Ready for App Store**:

- ✅ All core features implemented (auth, workouts, meals, health metrics)
- ✅ Professional UI/UX
- ✅ Error handling and offline support
- ✅ TestFlight beta testing passed
- ✅ App Store guidelines compliant

**Full Stack Integration**:

- ✅ Backend + iOS communicate securely
- ✅ JWT tokens managed properly
- ✅ Data syncs correctly
- ✅ User experience is seamless

### To-dos

- [ ] Create Swift data models matching backend entities (User, Workout, Meal, HealthMetrics)
- [ ] Build API service layer with networking code for backend communication
- [ ] Implement complete authentication flow (login, register, token storage)
- [ ] Build workout tracking feature end-to-end connecting to backend
- [ ] Create health metrics dashboard displaying backend calculations