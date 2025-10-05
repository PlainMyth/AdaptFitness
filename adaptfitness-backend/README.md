# AdaptFitness Backend API

A fitness app that redefines functionality and ease of getting into fitness!

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- PostgreSQL 13+
- npm or yarn

### Installation

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up environment variables**
   ```bash
   cp env.example .env
   # Edit .env with your database credentials
   ```

3. **Set up PostgreSQL database**
   ```bash
   # Create database
   createdb adaptfitness
   ```

4. **Start the development server**
   ```bash
   npm run start:dev
   ```

The API will be available at `http://localhost:3000`

## 📚 API Endpoints

### Health Check
- `GET /health` - API health status
- `GET /` - Welcome message and API info

### Authentication
- `POST /auth/register` - Register a new user
- `POST /auth/login` - Login user
- `GET /auth/profile` - Get user profile (protected)
- `GET /auth/validate` - Validate JWT token (protected)

### Users
- `GET /users/profile` - Get current user profile (protected)
- `PUT /users/profile` - Update current user profile (protected)
- `GET /users/:id` - Get user by ID (protected)
- `GET /users` - Get all users (protected)
- `DELETE /users/:id` - Delete user (protected)

### Workouts
- `POST /workouts` - Create workout (protected)
- `GET /workouts` - Get user workouts (protected)
- `GET /workouts/streak/current` - Get current workout streak (protected)
- `GET /workouts/:id` - Get workout by ID (protected)
- `PUT /workouts/:id` - Update workout (protected)
- `DELETE /workouts/:id` - Delete workout (protected)

### Meals
- `POST /meals` - Create meal (protected)
- `GET /meals` - Get user meals (protected)
- `GET /meals/streak/current` - Get current meal logging streak (protected)
- `GET /meals/:id` - Get meal by ID (protected)
- `PUT /meals/:id` - Update meal (protected)
- `DELETE /meals/:id` - Delete meal (protected)

### Health Metrics & Body Composition
- `POST /health-metrics` - Create health metrics entry (protected)
- `GET /health-metrics` - Get user health metrics (protected)
- `GET /health-metrics/latest` - Get latest health metrics (protected)
- `GET /health-metrics/calculations` - Get calculated health metrics (protected)
- `GET /health-metrics/:id` - Get health metrics by ID (protected)
- `PATCH /health-metrics/:id` - Update health metrics (protected)
- `DELETE /health-metrics/:id` - Delete health metrics (protected)

## 🏗️ Architecture

- **Framework**: NestJS
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: Manual service-level validation
- **Testing**: Jest with comprehensive test coverage
- **Health Metrics**: Advanced body composition calculations

## 🧪 Testing

```bash
# Run unit tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:cov

# Run e2e tests
npm run test:e2e
```

## 📝 Development

```bash
# Start development server
npm run start:dev

# Build for production
npm run build

# Start production server
npm start

# Lint code
npm run lint

# Format code
npm run format
```

## 🔧 Configuration

Environment variables in `.env`:

```bash
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
DATABASE_NAME=adaptfitness

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h

# App
PORT=3000
NODE_ENV=development
```

## 🎯 Key Features

### Health Metrics & Body Composition
- **BMI Calculation**: Body Mass Index with categorization
- **RMR Calculation**: Resting Metabolic Rate using Mifflin-St Jeor Equation
- **TDEE Calculation**: Total Daily Energy Expenditure
- **Lean Body Mass**: Calculated using Boer formula
- **Skeletal Muscle Mass**: Advanced muscle mass calculations
- **ABSI**: A Body Shape Index for health assessment
- **Waist-to-Hip Ratio**: Health risk assessment
- **Waist-to-Height Ratio**: Body shape analysis
- **Calorie Deficit**: Weight loss calculations
- **Maximum Fat Loss**: Safe weight loss recommendations

### Streak Tracking
- **Workout Streaks**: Track consecutive workout days
- **Meal Logging Streaks**: Track consecutive meal logging days
- **Timezone Support**: Accurate streak calculations across timezones
- **Streak History**: Track streak patterns and achievements

### Advanced Validation
- **Service-Level Validation**: Comprehensive input validation
- **Type Safety**: Full TypeScript support
- **Error Handling**: Detailed error messages and status codes
- **Data Integrity**: Ensures data consistency and accuracy

## 📊 Database Schema

### Users
- id (UUID, Primary Key)
- email (String, Unique)
- password (String, Hashed)
- firstName, lastName (String)
- dateOfBirth, height, weight (Optional)
- gender (Enum: male, female, other)
- activityLevel (Enum: sedentary, lightly_active, moderately_active, very_active, extremely_active)
- activityLevelMultiplier (Decimal: 1.2, 1.375, 1.55, 1.725, 1.9)
- isActive (Boolean)
- timestamps

### Workouts
- id (UUID, Primary Key)
- name, description (String)
- startTime, endTime (Timestamp)
- totalCaloriesBurned, totalDuration (Number)
- workoutType (Enum: cardio, strength, flexibility, sports, other)
- isCompleted (Boolean)
- userId (UUID, Foreign Key)
- timestamps

### Meals
- id (UUID, Primary Key)
- name, description (String)
- mealTime (Timestamp)
- totalCalories (Number)
- notes (String)
- mealType (Enum: breakfast, lunch, dinner, snack, other)
- userId (UUID, Foreign Key)
- timestamps

### Health Metrics
- id (UUID, Primary Key)
- userId (UUID, Foreign Key)
- weight, height (Decimal)
- bodyFatPercentage (Decimal)
- muscleMass (Decimal)
- boneDensity (Decimal)
- measurements (JSON: waist, hip, chest, arm, thigh)
- calculatedMetrics (JSON: BMI, RMR, TDEE, etc.)
- timestamps

## 🚀 Deployment

1. Build the application: `npm run build`
2. Set production environment variables
3. Run database migrations
4. Start the application: `npm start`

## 📄 License

MIT
