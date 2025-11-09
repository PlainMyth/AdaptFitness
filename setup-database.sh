#!/bin/bash

echo "🗄️  Setting up PostgreSQL Database for AdaptFitness"
echo "================================================="

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "📦 Installing PostgreSQL..."
    brew install postgresql
fi

# Start PostgreSQL service
echo "🚀 Starting PostgreSQL service..."
brew services start postgresql

# Wait a moment for the service to start
sleep 3

# Create the database
echo "🏗️  Creating adaptfitness database..."
createdb adaptfitness

# Check if database was created successfully
if [ $? -eq 0 ]; then
    echo "✅ Database 'adaptfitness' created successfully!"
else
    echo "⚠️  Database might already exist or there was an issue."
fi

echo ""
echo "🎉 Database setup complete!"
echo ""
echo "Next steps:"
echo "1. Start the backend server: cd adaptfitness-backend && npm run start:dev"
echo "2. Test authentication: ./test-auth.sh"
echo "3. Test goal calendar: ./test-goal-calendar-with-auth.sh"
echo ""
echo "Database connection details:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: adaptfitness"
echo "  Username: postgres"
echo "  Password: password"
