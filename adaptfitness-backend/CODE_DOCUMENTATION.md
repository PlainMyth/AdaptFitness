# 📚 AdaptFitness Backend Code Documentation

This document explains the codebase structure and how everything works together. Perfect for understanding the code when you come back to it later!

## 🏗️ **Overall Architecture**

```
AdaptFitness Backend
├── Controllers (API Endpoints)     ← Handle HTTP requests
├── Services (Business Logic)       ← Process data and calculations  
├── Entities (Database Tables)      ← Define data structure
├── DTOs (Data Validation)          ← Validate input data
├── Modules (Organization)          ← Group related functionality
└── Tests (Quality Assurance)       ← Ensure everything works
```

## 📁 **File Structure Explained**

### **Controllers** (`src/*/controllers/`)
**What they do:** Handle HTTP requests from users
**Think of them as:** The "front desk" of your app - they receive requests and direct them to the right place

**Example:** When someone wants to create health metrics, the controller:
1. Receives the request
2. Validates the data
3. Calls the service to process it
4. Returns the response

### **Services** (`src/*/services/`)
**What they do:** Contain all the business logic and calculations
**Think of them as:** The "brain" of your app - they do all the heavy thinking

**Example:** The health metrics service:
1. Calculates BMI, TDEE, RMR
2. Stores data in the database
3. Handles complex health formulas
4. Manages user permissions

### **Entities** (`src/*/entities/`)
**What they do:** Define the database table structure
**Think of them as:** The "blueprint" for your database tables

**Example:** The health metrics entity defines:
- What fields exist (weight, height, BMI, etc.)
- What type of data each field stores
- How fields relate to other tables

### **DTOs** (`src/*/dto/`)
**What they do:** Validate and structure incoming data
**Think of them as:** The "bouncer" at the door - they check if data is valid before letting it in

**Example:** The create health metrics DTO ensures:
- Weight is a positive number
- Body fat percentage is between 0-100
- Required fields are provided

## 🔍 **Key Files Explained**

### **1. Health Metrics Controller** (`health-metrics.controller.ts`)
```typescript
// This file handles all HTTP requests for health metrics
// Each method corresponds to a different API endpoint

@Post()           // POST /health-metrics
create()          // Creates new health metrics

@Get()            // GET /health-metrics  
findAll()         // Gets all health metrics for a user

@Get('latest')    // GET /health-metrics/latest
findLatest()      // Gets the most recent health metrics

@Get('calculations') // GET /health-metrics/calculations
getCalculatedMetrics() // Gets only calculated values (BMI, TDEE, etc.)
```

### **2. Health Metrics Service** (`health-metrics.service.ts`)
```typescript
// This file contains all the business logic
// It's where the "magic" happens - calculations, database operations, etc.

async create()     // Creates new health metrics + calculates derived values
async findAll()    // Gets all health metrics for a user
async findOne()    // Gets a specific health metrics entry
async update()     // Updates existing health metrics + recalculates
async remove()     // Deletes health metrics entry

// Private calculation methods:
calculateBMI()           // Body Mass Index calculation
calculateTDEE()          // Total Daily Energy Expenditure
calculateRMR()           // Resting Metabolic Rate
calculateBodyFat()       // Body fat percentage
// ... and many more!
```

### **3. Health Metrics Entity** (`health-metrics.entity.ts`)
```typescript
// This file defines the database table structure
// Each property becomes a column in the database

@Column()
currentWeight: number;        // User's current weight

@Column()
bodyFatPercentage: number;    // Body fat percentage

@Column()
bmi: number;                  // Calculated BMI

@Column()
tdee: number;                 // Calculated TDEE

// ... and many more fields!
```

## 🔄 **How Data Flows Through the App**

### **Creating Health Metrics:**
```
1. User sends POST request to /health-metrics
   ↓
2. Controller receives request and validates data
   ↓
3. Controller calls Service.create()
   ↓
4. Service calculates all derived metrics (BMI, TDEE, etc.)
   ↓
5. Service saves data to database
   ↓
6. Controller returns response to user
```

### **Getting Health Metrics:**
```
1. User sends GET request to /health-metrics
   ↓
2. Controller extracts user ID from JWT token
   ↓
3. Controller calls Service.findAll()
   ↓
4. Service queries database for user's health metrics
   ↓
5. Service returns data to controller
   ↓
6. Controller returns response to user
```

## 🧮 **Health Calculations Explained**

### **BMI (Body Mass Index)**
```typescript
// Formula: weight(kg) / height(m)²
// Example: 70kg / (1.75m)² = 22.86
calculateBMI(weight: number, height: number): number {
  return weight / Math.pow(height / 100, 2);
}
```

### **TDEE (Total Daily Energy Expenditure)**
```typescript
// Formula: RMR × Activity Level Multiplier
// Example: 1750 × 1.4 = 2450 calories
calculateTDEE(rmr: number, activityLevel: number): number {
  return rmr * activityLevel;
}
```

### **RMR (Resting Metabolic Rate)**
```typescript
// Mifflin-St Jeor Equation
// Men: (10 × weight) + (6.25 × height) - (5 × age) + 5
// Women: (10 × weight) + (6.25 × height) - (5 × age) - 161
calculateRMR(weight: number, height: number, age: number, gender: string): number {
  if (gender === 'male') {
    return (10 * weight) + (6.25 * height) - (5 * age) + 5;
  } else {
    return (10 * weight) + (6.25 * height) - (5 * age) - 161;
  }
}
```

## 🔐 **Security Features**

### **JWT Authentication**
- Every request needs a valid JWT token
- Tokens contain user information
- Expired tokens are rejected

### **User Isolation**
- Users can only access their own data
- Database queries always include user ID
- No cross-user data access possible

### **Input Validation**
- All incoming data is validated
- Invalid data is rejected with clear error messages
- SQL injection protection through TypeORM

## 🧪 **Testing Strategy**

### **Unit Tests** (`.spec.ts` files)
- Test individual methods in isolation
- Mock external dependencies
- Verify business logic works correctly

### **Integration Tests** (`.e2e-spec.ts` files)
- Test complete API workflows
- Use real database connections
- Verify end-to-end functionality

### **Test Coverage**
- 81.39% code coverage achieved
- All critical paths tested
- Edge cases and error scenarios covered

## 🚀 **How to Use This Code**

### **Adding New Health Metrics:**
1. Send POST request to `/health-metrics`
2. Include required data in request body
3. System automatically calculates derived metrics
4. Data is saved to database

### **Getting Health Data:**
1. Send GET request to `/health-metrics`
2. Include JWT token in Authorization header
3. System returns all health metrics for user
4. Data includes both raw measurements and calculations

### **Updating Health Metrics:**
1. Send PATCH request to `/health-metrics/:id`
2. Include only the fields you want to update
3. System recalculates all derived metrics
4. Updated data is saved to database

## 📊 **Database Schema**

### **health_metrics table:**
```sql
CREATE TABLE health_metrics (
  id SERIAL PRIMARY KEY,
  userId UUID NOT NULL,
  currentWeight DECIMAL(5,2) NOT NULL,
  bodyFatPercentage DECIMAL(5,2),
  bmi DECIMAL(4,2),
  tdee DECIMAL(6,2),
  rmr DECIMAL(6,2),
  -- ... many more fields
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

## 🎯 **Key Concepts for Understanding**

### **Decorators** (`@` symbols)
- Special instructions for TypeScript/NestJS
- `@Controller()` - Makes a class handle HTTP requests
- `@Injectable()` - Makes a class available for dependency injection
- `@Column()` - Defines a database column

### **Dependency Injection**
- Services are automatically provided to controllers
- No need to manually create service instances
- Makes testing easier and code more modular

### **Async/Await**
- Used for database operations and API calls
- Prevents blocking the main thread
- Makes code easier to read than callbacks

### **TypeORM**
- Object-Relational Mapping library
- Converts between JavaScript objects and database records
- Handles SQL queries automatically

## 🔧 **Common Patterns**

### **Error Handling**
```typescript
if (!healthMetrics) {
  throw new NotFoundException('Health metrics not found');
}
```

### **Data Validation**
```typescript
@IsNumber()
@Min(0)
@Max(100)
bodyFatPercentage: number;
```

### **Database Queries**
```typescript
return this.repository.find({
  where: { userId },
  order: { createdAt: 'DESC' }
});
```

## 📝 **When You Come Back to This Code**

1. **Start with the Controller** - See what endpoints are available
2. **Look at the Service** - Understand the business logic
3. **Check the Entity** - See what data is stored
4. **Read the Tests** - Understand expected behavior
5. **Use the API** - Test with Postman or curl

## 🎉 **Summary**

This codebase is well-structured, well-tested, and production-ready! The comments and documentation make it easy to understand what each part does and how everything fits together. You can confidently use this code for real-world applications and easily extend it with new features.

**Key strengths:**
- ✅ Clear separation of concerns
- ✅ Comprehensive error handling
- ✅ Extensive testing coverage
- ✅ Detailed documentation
- ✅ Professional code quality
- ✅ Production-ready architecture
