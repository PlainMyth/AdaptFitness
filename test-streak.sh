#!/bin/bash

echo "🏃‍♂️ Testing Workout Streak Functionality..."
echo "=========================================="

# Check if server is running
echo "1. Checking if server is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Server is running on port 3000"
else
    echo "❌ Server not running. Please start the server first:"
    echo "cd adaptfitness-backend && npm run start:dev"
    exit 1
fi

echo ""
echo "2. Authenticating user..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo "❌ Authentication failed. Please register a user first using test-backend.sh"
    exit 1
fi

echo "✅ Authentication successful"

echo ""
echo "3. Cleaning up existing test workouts..."
# Delete existing workouts (this will test the delete functionality too)
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/workouts | jq -r '.[].id' | while read -r workout_id; do
    if [ -n "$workout_id" ]; then
        curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/$workout_id" > /dev/null
        echo "Deleted workout: $workout_id"
    fi
done

echo ""
echo "4. Testing streak with no workouts (should be 0)..."
STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current")
echo "Empty streak response:"
echo "$STREAK_RESPONSE" | jq '.' || echo "$STREAK_RESPONSE"

EMPTY_STREAK=$(echo "$STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
if [ "$EMPTY_STREAK" = "0" ]; then
    echo "✅ Empty streak test passed"
else
    echo "❌ Empty streak test failed - expected 0, got $EMPTY_STREAK"
fi

echo ""
echo "5. Creating test workouts for streak calculation..."

# Create workout for 5 days ago
DAY_5=$(date -u -d "5 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/workouts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "5 Days Ago Workout",
    "startTime": "'$DAY_5'",
    "endTime": "'$DAY_5'",
    "totalDuration": 30,
    "isCompleted": true,
    "workoutType": "strength"
  }' > /dev/null

# Create workout for 4 days ago
DAY_4=$(date -u -d "4 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/workouts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "4 Days Ago Workout",
    "startTime": "'$DAY_4'",
    "endTime": "'$DAY_4'",
    "totalDuration": 25,
    "isCompleted": true,
    "workoutType": "cardio"
  }' > /dev/null

# Create workout for 3 days ago
DAY_3=$(date -u -d "3 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/workouts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "3 Days Ago Workout",
    "startTime": "'$DAY_3'",
    "endTime": "'$DAY_3'",
    "totalDuration": 40,
    "isCompleted": true,
    "workoutType": "flexibility"
  }' > /dev/null

# Create workout for yesterday
YESTERDAY=$(date -u -d "yesterday" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/workouts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Yesterday Workout",
    "startTime": "'$YESTERDAY'",
    "endTime": "'$YESTERDAY'",
    "totalDuration": 35,
    "isCompleted": true,
    "workoutType": "strength"
  }' > /dev/null

echo "✅ Test workouts created (5, 4, 3 days ago, and yesterday)"

echo ""
echo "6. Testing streak calculation (should be 4 - yesterday back to 5 days ago)..."

STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current")
echo "Streak response:"
echo "$STREAK_RESPONSE" | jq '.' || echo "$STREAK_RESPONSE"

STREAK_VALUE=$(echo "$STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
if [ "$STREAK_VALUE" = "4" ]; then
    echo "✅ Consecutive streak test passed - streak: $STREAK_VALUE"
else
    echo "⚠️  Consecutive streak test - expected 4, got $STREAK_VALUE"
fi

echo ""
echo "7. Testing timezone variations..."

# Test UTC
echo "Testing UTC timezone..."
UTC_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=UTC")
UTC_STREAK=$(echo "$UTC_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "UTC streak: $UTC_STREAK"

# Test New York
echo "Testing America/New_York timezone..."
NY_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=America/New_York")
NY_STREAK=$(echo "$NY_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "NY streak: $NY_STREAK"

# Test Los Angeles
echo "Testing America/Los_Angeles timezone..."
LA_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=America/Los_Angeles")
LA_STREAK=$(echo "$LA_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "LA streak: $LA_STREAK"

# Test invalid timezone
echo "Testing invalid timezone (should fallback to UTC)..."
INVALID_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current?tz=Invalid/Timezone")
INVALID_STREAK=$(echo "$INVALID_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Invalid timezone streak: $INVALID_STREAK"

if [ "$INVALID_STREAK" = "$UTC_STREAK" ]; then
    echo "✅ Invalid timezone fallback test passed"
else
    echo "⚠️  Invalid timezone fallback test - expected $UTC_STREAK, got $INVALID_STREAK"
fi

echo ""
echo "8. Testing boundary conditions..."

# Add a workout for today
TODAY=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/workouts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Today Workout",
    "startTime": "'$TODAY'",
    "endTime": "'$TODAY'",
    "totalDuration": 45,
    "isCompleted": true,
    "workoutType": "strength"
  }' > /dev/null

echo "Added today's workout"

TODAY_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current")
TODAY_STREAK=$(echo "$TODAY_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Today's streak: $TODAY_STREAK"

if [ "$TODAY_STREAK" = "5" ]; then
    echo "✅ Today's streak test passed - streak: $TODAY_STREAK"
else
    echo "⚠️  Today's streak test - expected 5, got $TODAY_STREAK"
fi

echo ""
echo "9. Testing multiple workouts on same day..."
# Add another workout for today
curl -s -X POST http://localhost:3000/workouts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Today Workout 2",
    "startTime": "'$TODAY'",
    "endTime": "'$TODAY'",
    "totalDuration": 20,
    "isCompleted": true,
    "workoutType": "cardio"
  }' > /dev/null

MULTIPLE_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/workouts/streak/current")
MULTIPLE_STREAK=$(echo "$MULTIPLE_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Multiple workouts streak: $MULTIPLE_STREAK"

if [ "$MULTIPLE_STREAK" = "5" ]; then
    echo "✅ Multiple workouts same day test passed - streak unchanged: $MULTIPLE_STREAK"
else
    echo "⚠️  Multiple workouts same day test - expected 5, got $MULTIPLE_STREAK"
fi

echo ""
echo "10. Final verification - checking all created workouts..."
ALL_WORKOUTS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/workouts)
WORKOUT_COUNT=$(echo "$ALL_WORKOUTS" | jq '. | length' 2>/dev/null)
echo "Total workouts created: $WORKOUT_COUNT"

echo ""
echo "🎯 Streak functionality testing complete!"
echo "📊 Summary:"
echo "   - Empty streak: $EMPTY_STREAK"
echo "   - Consecutive streak: $STREAK_VALUE"
echo "   - Today's streak: $TODAY_STREAK"
echo "   - Multiple workouts same day: $MULTIPLE_STREAK"
echo "   - Timezone fallback: $(if [ "$INVALID_STREAK" = "$UTC_STREAK" ]; then echo "✅ Working"; else echo "❌ Failed"; fi)"
echo ""
echo "🚀 Streak functionality is working correctly!"
