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
- `GET /workouts/:id` - Get workout by ID (protected)
- `PUT /workouts/:id` - Update workout (protected)
- `DELETE /workouts/:id` - Delete workout (protected)

### Meals
- `POST /meals` - Create meal (protected)
- `GET /meals` - Get user meals (protected)
- `GET /meals/:id` - Get meal by ID (protected)
- `PUT /meals/:id` - Update meal (protected)
- `DELETE /meals/:id` - Delete meal (protected)

## 🏗️ Architecture

- **Framework**: NestJS
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: class-validator
- **Testing**: Jest

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

## 📊 Database Schema

### Users
- id (UUID, Primary Key)
- email (String, Unique)
- password (String, Hashed)
- firstName, lastName (String)
- dateOfBirth, height, weight (Optional)
- activityLevel (Enum)
- isActive (Boolean)
- timestamps

### Workouts
- id (UUID, Primary Key)
- name, description (String)
- startTime, endTime (Timestamp)
- totalCaloriesBurned, totalDuration (Number)
- workoutType (Enum)
- isCompleted (Boolean)
- userId (UUID, Foreign Key)
- timestamps

### Meals
- id (UUID, Primary Key)
- name, description (String)
- mealTime (Timestamp)
- nutritional data (calories, protein, carbs, fat, etc.)
- mealType (Enum)
- userId (UUID, Foreign Key)
- timestamps

## 🚀 Deployment

1. Build the application: `npm run build`
2. Set production environment variables
3. Run database migrations
4. Start the application: `npm start`

## 📄 License

MIT
