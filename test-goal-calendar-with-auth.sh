#!/bin/bash

# Goal Calendar API Test Script with Authentication
# This script demonstrates the goal calendar functionality with proper user registration and login

BASE_URL="http://localhost:3000"
JWT_TOKEN=""
TEST_EMAIL="test@example.com"
TEST_PASSWORD="password123"

echo "🏋️‍♀️ Goal Calendar API Test Script with Authentication"
echo "=================================================="

# Function to make authenticated requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$data" ]; then
        curl -s -X $method \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $JWT_TOKEN" \
            -d "$data" \
            "$BASE_URL$endpoint"
    else
        curl -s -X $method \
            -H "Authorization: Bearer $JWT_TOKEN" \
            "$BASE_URL$endpoint"
    fi
}

# Function to register a new user
register_user() {
    echo "📝 Registering new test user..."
    RESPONSE=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{
            "email": "'$TEST_EMAIL'",
            "password": "'$TEST_PASSWORD'",
            "firstName": "Test",
            "lastName": "User"
        }' \
        "$BASE_URL/auth/register")
    
    echo "Registration response:"
    echo $RESPONSE | jq '.'
    
    # Check if registration was successful
    if echo $RESPONSE | jq -e '.message' > /dev/null; then
        echo "✅ User registration successful"
        return 0
    else
        echo "⚠️  User might already exist, trying to login..."
        return 1
    fi
}

# Function to login and get JWT token
login() {
    echo "🔐 Logging in..."
    RESPONSE=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{
            "email": "'$TEST_EMAIL'",
            "password": "'$TEST_PASSWORD'"
        }' \
        "$BASE_URL/auth/login")
    
    echo "Login response:"
    echo $RESPONSE | jq '.'
    
    JWT_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    
    if [ "$JWT_TOKEN" = "null" ] || [ -z "$JWT_TOKEN" ]; then
        echo "❌ Login failed. Please check credentials or try registering first."
        exit 1
    fi
    
    echo "✅ Login successful"
    echo "🔑 JWT Token: ${JWT_TOKEN:0:50}..."
}

# Function to get current week dates
get_current_week() {
    # Get current date
    TODAY=$(date +%Y-%m-%d)
    
    # Get day of week (1=Monday, 7=Sunday)
    DOW=$(date +%u)
    
    # Calculate Monday of current week
    DAYS_TO_MONDAY=$((DOW - 1))
    WEEK_START=$(date -v-${DAYS_TO_MONDAY}d +%Y-%m-%d)
    
    # Calculate Sunday of current week
    DAYS_TO_SUNDAY=$((7 - DOW))
    WEEK_END=$(date -v+${DAYS_TO_SUNDAY}d +%Y-%m-%d)
    
    echo "$WEEK_START,$WEEK_END"
}

# Main test flow
echo ""
echo "📋 Testing Goal Calendar Functionality with Authentication"
echo "========================================================="

# Step 1: Try to register user (will fail if user already exists)
register_user

# Step 2: Login (works whether user was just created or already existed)
login

# Step 3: Get current week dates
WEEK_DATES=$(get_current_week)
WEEK_START=$(echo $WEEK_DATES | cut -d',' -f1)
WEEK_END=$(echo $WEEK_DATES | cut -d',' -f2)

echo "📅 Current week: $WEEK_START to $WEEK_END"

# Step 4: Create sample goals for the current week
echo ""
echo "🎯 Creating Weekly Goals..."

# Goal 1: Complete 5 workouts this week
echo "Creating workout count goal..."
make_request POST "/goal-calendar" '{
    "weekStartDate": "'$WEEK_START'",
    "weekEndDate": "'$WEEK_END'",
    "goalType": "workouts_count",
    "targetValue": 5,
    "description": "Complete 5 workouts this week",
    "workoutType": null,
    "isActive": true
}' | jq '.'

# Goal 2: Burn 1500 calories
echo "Creating calorie goal..."
make_request POST "/goal-calendar" '{
    "weekStartDate": "'$WEEK_START'",
    "weekEndDate": "'$WEEK_END'",
    "goalType": "total_calories",
    "targetValue": 1500,
    "description": "Burn 1500 calories this week",
    "workoutType": null,
    "isActive": true
}' | jq '.'

# Goal 3: Complete 3 strength workouts
echo "Creating strength workout goal..."
make_request POST "/goal-calendar" '{
    "weekStartDate": "'$WEEK_START'",
    "weekEndDate": "'$WEEK_END'",
    "goalType": "workouts_count",
    "targetValue": 3,
    "description": "Complete 3 strength training sessions",
    "workoutType": "strength",
    "isActive": true
}' | jq '.'

# Goal 4: Total 300 minutes of exercise
echo "Creating duration goal..."
make_request POST "/goal-calendar" '{
    "weekStartDate": "'$WEEK_START'",
    "weekEndDate": "'$WEEK_END'",
    "goalType": "total_duration",
    "targetValue": 300,
    "description": "Exercise for 300 minutes this week",
    "workoutType": null,
    "isActive": true
}' | jq '.'

# Step 5: View current week goals
echo ""
echo "📊 Current Week Goals:"
make_request GET "/goal-calendar/current-week" | jq '.'

# Step 6: View goal statistics
echo ""
echo "📈 Goal Statistics:"
make_request GET "/goal-calendar/statistics" | jq '.'

# Step 7: Get calendar view for current month
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
echo ""
echo "📅 Calendar View for $CURRENT_YEAR-$CURRENT_MONTH:"
make_request GET "/goal-calendar/calendar-view?year=$CURRENT_YEAR&month=$CURRENT_MONTH" | jq '.'

# Step 8: Create some sample workouts to demonstrate progress tracking
echo ""
echo "🏋️‍♀️ Creating Sample Workouts..."

# Workout 1: Strength training
echo "Creating strength workout..."
make_request POST "/workouts" '{
    "name": "Upper Body Strength",
    "description": "Chest, shoulders, and arms workout",
    "startTime": "'$(date -v-2d +%Y-%m-%dT10:00:00Z)'",
    "endTime": "'$(date -v-2d +%Y-%m-%dT11:00:00Z)'",
    "totalCaloriesBurned": 400,
    "totalDuration": 60,
    "totalSets": 15,
    "totalReps": 120,
    "totalWeight": 2500,
    "workoutType": "strength",
    "isCompleted": true
}' | jq '.'

# Workout 2: Cardio
echo "Creating cardio workout..."
make_request POST "/workouts" '{
    "name": "Morning Run",
    "description": "5K morning run",
    "startTime": "'$(date -v-1d +%Y-%m-%dT07:00:00Z)'",
    "endTime": "'$(date -v-1d +%Y-%m-%dT07:45:00Z)'",
    "totalCaloriesBurned": 350,
    "totalDuration": 45,
    "totalSets": 0,
    "totalReps": 0,
    "totalWeight": 0,
    "workoutType": "cardio",
    "isCompleted": true
}' | jq '.'

# Workout 3: Another strength workout
echo "Creating another strength workout..."
make_request POST "/workouts" '{
    "name": "Lower Body Strength",
    "description": "Legs and glutes workout",
    "startTime": "'$(date +%Y-%m-%dT18:00:00Z)'",
    "endTime": "'$(date +%Y-%m-%dT19:00:00Z)'",
    "totalCaloriesBurned": 450,
    "totalDuration": 60,
    "totalSets": 12,
    "totalReps": 100,
    "totalWeight": 2000,
    "workoutType": "strength",
    "isCompleted": true
}' | jq '.'

# Step 9: Update all goal progress
echo ""
echo "🔄 Updating Goal Progress..."
make_request POST "/goal-calendar/update-all-progress" | jq '.'

# Step 10: View updated goals
echo ""
echo "📊 Updated Current Week Goals:"
make_request GET "/goal-calendar/current-week" | jq '.'

# Step 11: View updated statistics
echo ""
echo "📈 Updated Goal Statistics:"
make_request GET "/goal-calendar/statistics" | jq '.'

# Step 12: View all goals
echo ""
echo "📋 All Goals:"
make_request GET "/goal-calendar" | jq '.'

echo ""
echo "✅ Goal Calendar API test with authentication completed!"
echo ""
echo "🎯 Key Features Demonstrated:"
echo "   • User registration and authentication"
echo "   • Creating weekly fitness goals"
echo "   • Tracking progress against workout data"
echo "   • Calendar-based goal visualization"
echo "   • Goal statistics and completion tracking"
echo "   • Integration with workout module"
echo ""
echo "📝 API Endpoints Used:"
echo "   • POST /auth/register - User registration"
echo "   • POST /auth/login - User authentication"
echo "   • POST /goal-calendar - Create goals"
echo "   • GET /goal-calendar/current-week - View current week goals"
echo "   • GET /goal-calendar/statistics - View goal statistics"
echo "   • GET /goal-calendar/calendar-view - Calendar visualization"
echo "   • POST /goal-calendar/update-all-progress - Update progress"
echo "   • POST /workouts - Create sample workouts"
echo ""
echo "🔑 Test User Credentials:"
echo "   Email: $TEST_EMAIL"
echo "   Password: $TEST_PASSWORD"
echo ""
