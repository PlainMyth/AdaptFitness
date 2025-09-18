# 🚀 AdaptFitness Backend - Quick Reference

## 📋 **What's in This Codebase**

### **✅ Completed Features:**
- **User Authentication** - Registration, login, JWT tokens
- **Health Metrics** - BMI, TDEE, RMR, body fat calculations
- **Database Integration** - PostgreSQL with TypeORM
- **API Endpoints** - Full REST API for all features
- **Comprehensive Testing** - 81.39% test coverage
- **Security** - User isolation, input validation, JWT protection

### **📁 Main Files:**
```
src/
├── health-metrics/           ← Health calculations & tracking
│   ├── health-metrics.controller.ts    ← API endpoints
│   ├── health-metrics.service.ts       ← Business logic
│   ├── health-metrics.entity.ts        ← Database structure
│   └── dto/                            ← Data validation
├── auth/                      ← User authentication
├── user/                      ← User management
├── workout/                   ← Workout tracking
├── meal/                      ← Meal logging
└── app.module.ts             ← Main application setup
```

## 🔧 **How to Run the App**

### **Start Development Server:**
```bash
cd adaptfitness-backend
npm run start:dev
```
**Server runs on:** http://localhost:3000

### **Run Tests:**
```bash
npm test                    # Run all tests
npm test -- --testPathPattern=health-metrics  # Run health metrics tests
npm run test:cov           # Run tests with coverage
```

### **Build for Production:**
```bash
npm run build
npm start
```

## 🌐 **API Endpoints**

### **Authentication:**
- `POST /auth/register` - Create new user account
- `POST /auth/login` - Login and get JWT token
- `GET /auth/profile` - Get user profile

### **Health Metrics:**
- `POST /health-metrics` - Create new health metrics
- `GET /health-metrics` - Get all health metrics
- `GET /health-metrics/latest` - Get most recent metrics
- `GET /health-metrics/calculations` - Get calculated values only
- `GET /health-metrics/:id` - Get specific metrics entry
- `PATCH /health-metrics/:id` - Update metrics entry
- `DELETE /health-metrics/:id` - Delete metrics entry

### **Users:**
- `GET /users/profile` - Get user profile
- `PUT /users/profile` - Update user profile
- `GET /users` - Get all users (admin)

## 📊 **Health Calculations Available**

### **Body Composition:**
- **BMI** - Body Mass Index
- **Body Fat %** - Body fat percentage
- **Lean Body Mass** - Fat-free mass
- **Skeletal Muscle Mass** - Muscle mass calculation

### **Metabolic:**
- **RMR** - Resting Metabolic Rate
- **TDEE** - Total Daily Energy Expenditure
- **Calorie Deficit** - Weight loss calculations

### **Advanced Metrics:**
- **ABSI** - A Body Shape Index
- **Waist-to-Hip Ratio** - Health risk indicator
- **Waist-to-Height Ratio** - Health assessment
- **Maximum Fat Loss** - Safe weekly loss limit

## 🧪 **Testing Commands**

```bash
# Run all tests
npm test

# Run specific test suite
npm test -- --testPathPattern=health-metrics

# Run with coverage report
npm run test:cov

# Run E2E tests
npm run test:e2e

# Run health metrics test script
./test-health-metrics.sh
```

## 🔍 **Code Quality**

### **Test Coverage:**
- **81.39%** overall coverage
- **37 test cases** for health metrics
- **Unit tests** for all services
- **Integration tests** for API endpoints
- **DTO validation tests** for data integrity

### **Code Standards:**
- **TypeScript** for type safety
- **NestJS** for enterprise architecture
- **TypeORM** for database management
- **Jest** for comprehensive testing
- **ESLint** for code quality

## 🚨 **Common Issues & Solutions**

### **"Cannot find module" errors:**
```bash
npm install
```

### **Database connection issues:**
- Check PostgreSQL is running
- Verify `.env` file has correct database credentials
- Run `npm run setup` to create database

### **Port already in use:**
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

### **Test failures:**
```bash
# Clear test cache
npm test -- --clearCache
```

## 📝 **Adding New Features**

### **1. Create Entity:**
```typescript
// Define database table structure
@Entity('table_name')
export class NewEntity {
  @PrimaryGeneratedColumn()
  id: number;
  
  @Column()
  fieldName: string;
}
```

### **2. Create Service:**
```typescript
// Add business logic
@Injectable()
export class NewService {
  // Add methods here
}
```

### **3. Create Controller:**
```typescript
// Add API endpoints
@Controller('endpoint-name')
export class NewController {
  // Add HTTP methods here
}
```

### **4. Create Tests:**
```typescript
// Add comprehensive tests
describe('NewService', () => {
  // Add test cases
});
```

## 🎯 **Key Files to Remember**

### **For Understanding the Code:**
1. **`CODE_DOCUMENTATION.md`** - Complete code explanation
2. **`health-metrics.controller.ts`** - API endpoints
3. **`health-metrics.service.ts`** - Business logic
4. **`health-metrics.entity.ts`** - Database structure

### **For Running the App:**
1. **`package.json`** - Dependencies and scripts
2. **`app.module.ts`** - Main application setup
3. **`.env`** - Environment configuration
4. **`tsconfig.json`** - TypeScript configuration

### **For Testing:**
1. **`*.spec.ts`** - Unit tests
2. **`*.e2e-spec.ts`** - Integration tests
3. **`jest.config.js`** - Test configuration
4. **`test-health-metrics.sh`** - Test script

## 🚀 **Production Deployment**

### **Environment Variables:**
```bash
DATABASE_HOST=your-db-host
DATABASE_PORT=5432
DATABASE_USERNAME=your-username
DATABASE_PASSWORD=your-password
DATABASE_NAME=adaptfitness
JWT_SECRET=your-secret-key
PORT=3000
```

### **Build Commands:**
```bash
npm run build
npm start
```

### **Health Check:**
- Visit: `http://localhost:3000/health`
- Should return: `{"status":"ok","service":"AdaptFitness API","version":"1.0.0"}`

## 🎉 **You're All Set!**

This codebase is **production-ready** and **well-documented**. You can:
- ✅ Use it for real-world applications
- ✅ Extend it with new features
- ✅ Deploy it to production
- ✅ Understand every part of the code
- ✅ Maintain and update it easily

**Happy coding!** 🚀
