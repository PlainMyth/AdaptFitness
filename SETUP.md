# 🏋️ AdaptFitness Setup Guide

Welcome to AdaptFitness! This guide will help you get the backend API up and running.

## 📋 Prerequisites

Before you start, make sure you have:

1. **Node.js 20+** - [Download here](https://nodejs.org/)
2. **PostgreSQL 13+** - [Download here](https://www.postgresql.org/download/)
3. **Git** (already installed)

## 🚀 Quick Setup

### 1. Install Node.js

**Option A: Download from website**
- Go to [nodejs.org](https://nodejs.org/)
- Download the LTS version (20+)
- Run the installer

**Option B: Install with Homebrew (if you have it)**
```bash
brew install node
```

**Option C: Install with nvm (Node Version Manager)**
```bash
# Install nvm first
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Restart terminal or run:
source ~/.bashrc

# Install Node.js 20
nvm install 20
nvm use 20
```

### 2. Install PostgreSQL

**Option A: Download from website**
- Go to [postgresql.org](https://www.postgresql.org/download/)
- Download and install PostgreSQL

**Option B: Install with Homebrew**
```bash
brew install postgresql
brew services start postgresql
```

### 3. Set up the Backend

```bash
# Navigate to the backend directory
cd adaptfitness-backend

# Run the setup script
./setup.sh

# Or manually:
npm install
cp env.example .env
```

### 4. Configure Database

1. **Start PostgreSQL service**
   ```bash
   # On macOS with Homebrew
   brew services start postgresql
   
   # On Linux
   sudo systemctl start postgresql
   
   # On Windows
   # Start PostgreSQL service from Services
   ```

2. **Create the database**
   ```bash
   createdb adaptfitness
   ```

3. **Update .env file**
   ```bash
   # Edit .env with your database credentials
   nano .env
   ```

### 5. Start the Development Server

```bash
npm run start:dev
```

The API will be available at: **http://localhost:3000**

## 🧪 Test the API

### Health Check
```bash
curl http://localhost:3000/health
```

### Register a User
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## 📁 Project Structure

```
adaptfitness-backend/
├── src/
│   ├── auth/           # Authentication module
│   ├── user/           # User management
│   ├── workout/        # Workout tracking
│   ├── meal/           # Meal logging
│   ├── app.module.ts   # Main app module
│   └── main.ts         # Application entry point
├── package.json        # Dependencies and scripts
├── tsconfig.json       # TypeScript configuration
├── jest.config.js      # Testing configuration
└── README.md          # API documentation
```

## 🔧 Available Scripts

```bash
# Development
npm run start:dev      # Start with hot reload
npm run build         # Build for production
npm start            # Start production server

# Testing
npm test             # Run unit tests
npm run test:watch   # Run tests in watch mode
npm run test:cov     # Run tests with coverage

# Code Quality
npm run lint         # Lint code
npm run format       # Format code
```

## 🐛 Troubleshooting

### Node.js not found
- Make sure Node.js is installed and in your PATH
- Try restarting your terminal
- Check with `node --version`

### Database connection failed
- Make sure PostgreSQL is running
- Check your database credentials in `.env`
- Verify the database exists: `psql -l`

### Port already in use
- Change the PORT in `.env` file
- Or kill the process using port 3000

### Permission denied on setup.sh
```bash
chmod +x setup.sh
```

## 📚 Next Steps

1. **Test the API endpoints** using the examples above
2. **Set up the iOS frontend** (coming soon!)
3. **Add more features** like barcode scanning for meals
4. **Deploy to production** when ready

## 🆘 Need Help?

- Check the [API documentation](adaptfitness-backend/README.md)
- Review the [project context](ai-context/)
- Open an issue on GitHub

Happy coding! 🚀
