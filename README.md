# 🏋️ UltimateFitness

<img width="500" height="500" alt="UltimateFitness Logo" src="UltimateFitness_Logo_Gradient.png" />

A fitness app that redefines the functionality and ease of getting into fitness!

## 🎯 **Project Overview**

UltimateFitness is a comprehensive fitness tracking application built for the CPSC 491 Capstone Project. It combines workout tracking, nutrition logging, and progress analytics to help users achieve their fitness goals.

## 🚀 **Current Status**

### ✅ **Completed Features**
- **Backend API (NestJS)** - Complete with authentication, user management, workout tracking, and meal logging
- **Database Integration** - PostgreSQL with TypeORM entities and relationships
- **Security** - JWT authentication with bcrypt password hashing
- **Testing** - Jest framework with comprehensive test coverage
- **Documentation** - Complete API documentation and setup guides

### 🚧 **Next Phase (8 New Backend Modules)**
- Streak Tracking System
- Smart Notifications & Engagement System
- Food Intelligence & Scanning System
- Analytics & Reporting System
- Enhanced Workout Intelligence
- Goal Management System
- Social Features & Community
- Health Metrics & Body Composition

## 📖 **Quick Start Guide**

### **Prerequisites**
- Node.js 20+
- PostgreSQL 13+
- Git

### **Setup Instructions**
```bash
# Clone the repository
git clone https://github.com/UltimateFitness/UltimateFitness.git
cd UltimateFitness

# Navigate to backend
cd adaptfitness-backend

# Install dependencies
npm install

# Set up environment variables
cp env.example .env
# Edit .env with your database credentials

# Create PostgreSQL database
createdb ultimatefitness

# Start the development server
npm run start:dev
```

### **API Base URL**: `http://localhost:3000`

## 📚 **API Documentation**

### **Authentication**
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/profile` - Get user profile (protected)

### **User Management**
- `GET /users/profile` - Get current user profile
- `PUT /users/profile` - Update user profile
- `GET /users/:id` - Get user by ID

### **Workout Tracking**
- `POST /workouts` - Create workout
- `GET /workouts` - Get user workouts
- `PUT /workouts/:id` - Update workout
- `DELETE /workouts/:id` - Delete workout

### **Meal Logging**
- `POST /meals` - Create meal
- `GET /meals` - Get user meals
- `PUT /meals/:id` - Update meal
- `DELETE /meals/:id` - Delete meal

## 🧪 **Testing**

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:cov

# Test API endpoints
./test-api.sh
```

## 🏗️ **Architecture**

- **Backend**: NestJS with TypeScript
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with Passport
- **Validation**: class-validator
- **Testing**: Jest
- **Linting**: ESLint with Prettier

## 📁 **Project Structure**

```
UltimateFitness/
├── adaptfitness-backend/     # NestJS Backend API
│   ├── src/
│   │   ├── auth/            # Authentication system
│   │   ├── user/            # User management
│   │   ├── workout/         # Workout tracking
│   │   ├── meal/            # Meal logging
│   │   └── main.ts          # App entry point
│   ├── package.json         # Dependencies
│   └── README.md           # Backend documentation
├── adaptfitness-ios/        # iOS Frontend
├── ai-context/              # Project documentation
├── SETUP.md                 # Setup instructions
└── PROJECT_STATUS.md        # Project status and roadmap
```

## 🎓 **CPSC 491 Academic Alignment**

This project demonstrates:
- **Technical Complexity**: Complete backend system with authentication, database, and API
- **Real-world Application**: Practical fitness app with market relevance
- **Software Engineering**: Modular architecture, testing, documentation
- **Database Design**: Complex relationships, data modeling
- **Security**: JWT authentication, password hashing, protected routes
- **API Development**: RESTful services with comprehensive documentation

## 📄 **License**

MIT

## 👥 **Contributing**

This is a CPSC 491 Capstone Project. For collaboration, please contact the project team.

---

*Built with ❤️ for CPSC 491 Capstone Project*
