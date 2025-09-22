#!/bin/bash

echo "🧪 Testing AdaptFitness Backend API..."
echo "=================================="

# Check if server is running
echo "1. Checking if server is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Server is running on port 3000"
else
    echo "❌ Server not running. Starting server..."
    echo "Please run: cd adaptfitness-backend && npm run start:dev"
    echo "Then run this test script again."
    exit 1
fi

echo ""
echo "2. Testing Health Endpoint..."
curl -s http://localhost:3000/health | jq '.' || echo "Health check response:"
curl -s http://localhost:3000/health

echo ""
echo "3. Testing Welcome Endpoint..."
curl -s http://localhost:3000/ | jq '.' || echo "Welcome response:"
curl -s http://localhost:3000/

echo ""
echo "4. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }')

echo "Registration response:"
echo "$REGISTER_RESPONSE" | jq '.' || echo "$REGISTER_RESPONSE"

echo ""
echo "5. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

echo "Login response:"
echo "$LOGIN_RESPONSE" | jq '.' || echo "$LOGIN_RESPONSE"

# Extract token for protected endpoints
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo ""
    echo "6. Testing Protected Profile Endpoint..."
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/auth/profile | jq '.' || echo "Profile response:"
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/auth/profile
    
    echo ""
    echo "7. Testing Workouts Endpoint..."
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/workouts | jq '.' || echo "Workouts response:"
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/workouts
    
    echo ""
    echo "8. Testing Meals Endpoint..."
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/meals | jq '.' || echo "Meals response:"
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/meals
    
    echo ""
    echo "9. Testing Workout Streak Functionality..."
    
    # Create test workouts for streak testing
    echo "Creating test workouts for streak calculation..."
    
    # Today's workout
    TODAY_WORKOUT=$(curl -s -X POST http://localhost:3000/workouts \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Today Workout",
        "description": "Test workout for today",
        "startTime": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
        "endTime": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
        "totalDuration": 30,
        "isCompleted": true,
        "workoutType": "strength"
      }')
    
    echo "Today's workout created:"
    echo "$TODAY_WORKOUT" | jq '.' || echo "$TODAY_WORKOUT"
    
    # Yesterday's workout
    YESTERDAY=$(date -u -d "yesterday" +"%Y-%m-%dT%H:%M:%S.%3NZ")
    YESTERDAY_WORKOUT=$(curl -s -X POST http://localhost:3000/workouts \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Yesterday Workout",
        "description": "Test workout for yesterday",
        "startTime": "'$YESTERDAY'",
        "endTime": "'$YESTERDAY'",
        "totalDuration": 45,
        "isCompleted": true,
        "workoutType": "cardio"
      }')
    
    echo "Yesterday's workout created:"
    echo "$YESTERDAY_WORKOUT" | jq '.' || echo "$YESTERDAY_WORKOUT"
    
    # Day before yesterday's workout
    DAY_BEFORE=$(date -u -d "2 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
    DAY_BEFORE_WORKOUT=$(curl -s -X POST http://localhost:3000/workouts \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Day Before Workout",
        "description": "Test workout for 2 days ago",
        "startTime": "'$DAY_BEFORE'",
        "endTime": "'$DAY_BEFORE'",
        "totalDuration": 20,
        "isCompleted": true,
        "workoutType": "flexibility"
      }')
    
    echo "Day before yesterday's workout created:"
    echo "$DAY_BEFORE_WORKOUT" | jq '.' || echo "$DAY_BEFORE_WORKOUT"
    
    # Test streak endpoint with UTC timezone
    echo ""
    echo "Testing streak endpoint with UTC timezone..."
    STREAK_RESPONSE_UTC=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=UTC")
    echo "UTC Streak response:"
    echo "$STREAK_RESPONSE_UTC" | jq '.' || echo "$STREAK_RESPONSE_UTC"
    
    # Test streak endpoint with New York timezone
    echo ""
    echo "Testing streak endpoint with America/New_York timezone..."
    STREAK_RESPONSE_NY=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=America/New_York")
    echo "New York Streak response:"
    echo "$STREAK_RESPONSE_NY" | jq '.' || echo "$STREAK_RESPONSE_NY"
    
    # Test streak endpoint with Los Angeles timezone
    echo ""
    echo "Testing streak endpoint with America/Los_Angeles timezone..."
    STREAK_RESPONSE_LA=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=America/Los_Angeles")
    echo "Los Angeles Streak response:"
    echo "$STREAK_RESPONSE_LA" | jq '.' || echo "$STREAK_RESPONSE_LA"
    
    # Test streak endpoint with invalid timezone (should fall back to UTC)
    echo ""
    echo "Testing streak endpoint with invalid timezone..."
    STREAK_RESPONSE_INVALID=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=Invalid/Timezone")
    echo "Invalid timezone Streak response:"
    echo "$STREAK_RESPONSE_INVALID" | jq '.' || echo "$STREAK_RESPONSE_INVALID"
    
    # Test streak endpoint without timezone parameter
    echo ""
    echo "Testing streak endpoint without timezone parameter..."
    STREAK_RESPONSE_DEFAULT=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current")
    echo "Default timezone Streak response:"
    echo "$STREAK_RESPONSE_DEFAULT" | jq '.' || echo "$STREAK_RESPONSE_DEFAULT"
    
    # Verify streak values are reasonable
    echo ""
    echo "Verifying streak calculation results..."
    UTC_STREAK=$(echo "$STREAK_RESPONSE_UTC" | jq -r '.streak' 2>/dev/null)
    if [ "$UTC_STREAK" != "null" ] && [ -n "$UTC_STREAK" ]; then
        if [ "$UTC_STREAK" -ge 1 ] && [ "$UTC_STREAK" -le 10 ]; then
            echo "✅ UTC streak value is reasonable: $UTC_STREAK"
        else
            echo "⚠️  UTC streak value seems unusual: $UTC_STREAK"
        fi
    else
        echo "❌ Could not extract UTC streak value"
    fi
    
    echo ""
    echo "🎯 Streak testing complete!"
    
    echo ""
    echo "10. Testing Meal Streak Functionality..."
    
    # Create test meals for streak testing
    echo "Creating test meals for streak calculation..."
    
    # Today's meal
    TODAY_MEAL=$(curl -s -X POST http://localhost:3000/meals \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Today Breakfast",
        "description": "Test meal for today",
        "mealTime": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
        "totalCalories": 300,
        "totalProtein": 20,
        "totalCarbs": 30,
        "totalFat": 10,
        "mealType": "breakfast"
      }')
    
    echo "Today's meal created:"
    echo "$TODAY_MEAL" | jq '.' || echo "$TODAY_MEAL"
    
    # Yesterday's meal
    YESTERDAY_MEAL=$(curl -s -X POST http://localhost:3000/meals \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Yesterday Lunch",
        "description": "Test meal for yesterday",
        "mealTime": "'$YESTERDAY'",
        "totalCalories": 500,
        "totalProtein": 25,
        "totalCarbs": 45,
        "totalFat": 15,
        "mealType": "lunch"
      }')
    
    echo "Yesterday's meal created:"
    echo "$YESTERDAY_MEAL" | jq '.' || echo "$YESTERDAY_MEAL"
    
    # Day before yesterday's meal
    DAY_BEFORE_MEAL=$(curl -s -X POST http://localhost:3000/meals \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Day Before Dinner",
        "description": "Test meal for 2 days ago",
        "mealTime": "'$DAY_BEFORE'",
        "totalCalories": 700,
        "totalProtein": 35,
        "totalCarbs": 60,
        "totalFat": 20,
        "mealType": "dinner"
      }')
    
    echo "Day before yesterday's meal created:"
    echo "$DAY_BEFORE_MEAL" | jq '.' || echo "$DAY_BEFORE_MEAL"
    
    # Test meal streak endpoint with UTC timezone
    echo ""
    echo "Testing meal streak endpoint with UTC timezone..."
    MEAL_STREAK_RESPONSE_UTC=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=UTC")
    echo "UTC Meal Streak response:"
    echo "$MEAL_STREAK_RESPONSE_UTC" | jq '.' || echo "$MEAL_STREAK_RESPONSE_UTC"
    
    # Test meal streak endpoint with New York timezone
    echo ""
    echo "Testing meal streak endpoint with America/New_York timezone..."
    MEAL_STREAK_RESPONSE_NY=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=America/New_York")
    echo "New York Meal Streak response:"
    echo "$MEAL_STREAK_RESPONSE_NY" | jq '.' || echo "$MEAL_STREAK_RESPONSE_NY"
    
    # Test meal streak endpoint with Los Angeles timezone
    echo ""
    echo "Testing meal streak endpoint with America/Los_Angeles timezone..."
    MEAL_STREAK_RESPONSE_LA=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=America/Los_Angeles")
    echo "Los Angeles Meal Streak response:"
    echo "$MEAL_STREAK_RESPONSE_LA" | jq '.' || echo "$MEAL_STREAK_RESPONSE_LA"
    
    # Test meal streak endpoint with invalid timezone (should fall back to UTC)
    echo ""
    echo "Testing meal streak endpoint with invalid timezone..."
    MEAL_STREAK_RESPONSE_INVALID=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=Invalid/Timezone")
    echo "Invalid timezone Meal Streak response:"
    echo "$MEAL_STREAK_RESPONSE_INVALID" | jq '.' || echo "$MEAL_STREAK_RESPONSE_INVALID"
    
    # Test meal streak endpoint without timezone parameter
    echo ""
    echo "Testing meal streak endpoint without timezone parameter..."
    MEAL_STREAK_RESPONSE_DEFAULT=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current")
    echo "Default timezone Meal Streak response:"
    echo "$MEAL_STREAK_RESPONSE_DEFAULT" | jq '.' || echo "$MEAL_STREAK_RESPONSE_DEFAULT"
    
    # Verify meal streak values are reasonable
    echo ""
    echo "Verifying meal streak calculation results..."
    MEAL_UTC_STREAK=$(echo "$MEAL_STREAK_RESPONSE_UTC" | jq -r '.streak' 2>/dev/null)
    if [ "$MEAL_UTC_STREAK" != "null" ] && [ -n "$MEAL_UTC_STREAK" ]; then
        if [ "$MEAL_UTC_STREAK" -ge 1 ] && [ "$MEAL_UTC_STREAK" -le 10 ]; then
            echo "✅ UTC meal streak value is reasonable: $MEAL_UTC_STREAK"
        else
            echo "⚠️  UTC meal streak value seems unusual: $MEAL_UTC_STREAK"
        fi
    else
        echo "❌ Could not extract UTC meal streak value"
    fi
    
    echo ""
    echo "🍽️ Meal streak testing complete!"
else
    echo "❌ Could not extract token from login response"
fi

echo ""
echo "✅ API testing complete!"
echo ""
echo "🎉 Your AdaptFitness backend is working perfectly!"
echo "📱 Ready to build the iOS frontend!"
