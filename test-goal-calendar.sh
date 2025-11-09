#!/bin/bash

# Goal Calendar API Test Script
# This script demonstrates the goal calendar functionality with workout integration

BASE_URL="http://localhost:3000"
JWT_TOKEN=""

echo "🏋️‍♀️ Goal Calendar API Test Script"
echo "=================================="

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

# Function to login and get JWT token
login() {
    echo "🔐 Logging in..."
    RESPONSE=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{"email": "test@example.com", "password": "password123"}' \
        "$BASE_URL/auth/login")
    
    JWT_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    
    if [ "$JWT_TOKEN" = "null" ] || [ -z "$JWT_TOKEN" ]; then
        echo "❌ Login failed. Please check credentials."
        exit 1
    fi
    
    echo "✅ Login successful"
}

# Function to get current week dates
get_current_week() {
    # Get Monday of current week
    WEEK_START=$(date -v-mon +%Y-%m-%d)
    # Get Sunday of current week  
    WEEK_END=$(date -v-sun +%Y-%m-%d)
    echo "$WEEK_START,$WEEK_END"
}

# Main test flow
echo ""
echo "📋 Testing Goal Calendar Functionality"
echo "====================================="

# Step 1: Login
login

# Step 2: Get current week dates
WEEK_DATES=$(get_current_week)
WEEK_START=$(echo $WEEK_DATES | cut -d',' -f1)
WEEK_END=$(echo $WEEK_DATES | cut -d',' -f2)

echo "📅 Current week: $WEEK_START to $WEEK_END"

# Step 3: Create sample goals for the current week
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

# Step 4: View current week goals
echo ""
echo "📊 Current Week Goals:"
make_request GET "/goal-calendar/current-week" | jq '.'

# Step 5: View goal statistics
echo ""
echo "📈 Goal Statistics:"
make_request GET "/goal-calendar/statistics" | jq '.'

# Step 6: Get calendar view for current month
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
echo ""
echo "📅 Calendar View for $CURRENT_YEAR-$CURRENT_MONTH:"
make_request GET "/goal-calendar/calendar-view?year=$CURRENT_YEAR&month=$CURRENT_MONTH" | jq '.'

# Step 7: Create some sample workouts to demonstrate progress tracking
echo ""
echo "🏋️‍♀️ Creating Sample Workouts..."

# Workout 1: Strength training
make_request POST "/workout" '{
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
make_request POST "/workout" '{
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
make_request POST "/workout" '{
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

# Step 8: Update all goal progress
echo ""
echo "🔄 Updating Goal Progress..."
make_request POST "/goal-calendar/update-all-progress" | jq '.'

# Step 9: View updated goals
echo ""
echo "📊 Updated Current Week Goals:"
make_request GET "/goal-calendar/current-week" | jq '.'

# Step 10: View updated statistics
echo ""
echo "📈 Updated Goal Statistics:"
make_request GET "/goal-calendar/statistics" | jq '.'

# Step 11: View all goals
echo ""
echo "📋 All Goals:"
make_request GET "/goal-calendar" | jq '.'

echo ""
echo "✅ Goal Calendar API test completed!"
echo ""
echo "🎯 Key Features Demonstrated:"
echo "   • Creating weekly fitness goals"
echo "   • Tracking progress against workout data"
echo "   • Calendar-based goal visualization"
echo "   • Goal statistics and completion tracking"
echo "   • Integration with workout module"
echo ""
echo "📝 API Endpoints Used:"
echo "   • POST /goal-calendar - Create goals"
echo "   • GET /goal-calendar/current-week - View current week goals"
echo "   • GET /goal-calendar/statistics - View goal statistics"
echo "   • GET /goal-calendar/calendar-view - Calendar visualization"
echo "   • POST /goal-calendar/update-all-progress - Update progress"
echo "   • POST /workout - Create sample workouts"
echo ""
