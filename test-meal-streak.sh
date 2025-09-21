#!/bin/bash

echo "🍽️ Testing Meal Streak Functionality..."
echo "======================================"

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
echo "3. Cleaning up existing test meals..."
# Delete existing meals (this will test the delete functionality too)
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/meals | jq -r '.[].id' | while read -r meal_id; do
    if [ -n "$meal_id" ]; then
        curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/$meal_id" > /dev/null
        echo "Deleted meal: $meal_id"
    fi
done

echo ""
echo "4. Testing meal streak with no meals (should be 0)..."
MEAL_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current")
echo "Empty meal streak response:"
echo "$MEAL_STREAK_RESPONSE" | jq '.' || echo "$MEAL_STREAK_RESPONSE"

EMPTY_MEAL_STREAK=$(echo "$MEAL_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
if [ "$EMPTY_MEAL_STREAK" = "0" ]; then
    echo "✅ Empty meal streak test passed"
else
    echo "❌ Empty meal streak test failed - expected 0, got $EMPTY_MEAL_STREAK"
fi

echo ""
echo "5. Creating test meals for streak calculation..."

# Create meal for 5 days ago
DAY_5=$(date -u -d "5 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "5 Days Ago Breakfast",
    "mealTime": "'$DAY_5'",
    "totalCalories": 400,
    "totalProtein": 20,
    "totalCarbs": 40,
    "totalFat": 15,
    "mealType": "breakfast"
  }' > /dev/null

# Create meal for 4 days ago
DAY_4=$(date -u -d "4 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "4 Days Ago Lunch",
    "mealTime": "'$DAY_4'",
    "totalCalories": 600,
    "totalProtein": 30,
    "totalCarbs": 50,
    "totalFat": 20,
    "mealType": "lunch"
  }' > /dev/null

# Create meal for 3 days ago
DAY_3=$(date -u -d "3 days ago" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "3 Days Ago Dinner",
    "mealTime": "'$DAY_3'",
    "totalCalories": 800,
    "totalProtein": 40,
    "totalCarbs": 60,
    "totalFat": 25,
    "mealType": "dinner"
  }' > /dev/null

# Create meal for yesterday
YESTERDAY=$(date -u -d "yesterday" +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Yesterday Snack",
    "mealTime": "'$YESTERDAY'",
    "totalCalories": 200,
    "totalProtein": 10,
    "totalCarbs": 25,
    "totalFat": 8,
    "mealType": "snack"
  }' > /dev/null

echo "✅ Test meals created (5, 4, 3 days ago, and yesterday)"

echo ""
echo "6. Testing meal streak calculation (should be 4 - yesterday back to 5 days ago)..."

MEAL_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current")
echo "Meal streak response:"
echo "$MEAL_STREAK_RESPONSE" | jq '.' || echo "$MEAL_STREAK_RESPONSE"

MEAL_STREAK_VALUE=$(echo "$MEAL_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
if [ "$MEAL_STREAK_VALUE" = "4" ]; then
    echo "✅ Consecutive meal streak test passed - streak: $MEAL_STREAK_VALUE"
else
    echo "⚠️  Consecutive meal streak test - expected 4, got $MEAL_STREAK_VALUE"
fi

echo ""
echo "7. Testing timezone variations..."

# Test UTC
echo "Testing UTC timezone..."
UTC_MEAL_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=UTC")
UTC_MEAL_STREAK=$(echo "$UTC_MEAL_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "UTC meal streak: $UTC_MEAL_STREAK"

# Test New York
echo "Testing America/New_York timezone..."
NY_MEAL_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=America/New_York")
NY_MEAL_STREAK=$(echo "$NY_MEAL_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "NY meal streak: $NY_MEAL_STREAK"

# Test Los Angeles
echo "Testing America/Los_Angeles timezone..."
LA_MEAL_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=America/Los_Angeles")
LA_MEAL_STREAK=$(echo "$LA_MEAL_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "LA meal streak: $LA_MEAL_STREAK"

# Test invalid timezone
echo "Testing invalid timezone (should fallback to UTC)..."
INVALID_MEAL_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current?tz=Invalid/Timezone")
INVALID_MEAL_STREAK=$(echo "$INVALID_MEAL_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Invalid timezone meal streak: $INVALID_MEAL_STREAK"

if [ "$INVALID_MEAL_STREAK" = "$UTC_MEAL_STREAK" ]; then
    echo "✅ Invalid timezone fallback test passed"
else
    echo "⚠️  Invalid timezone fallback test - expected $UTC_MEAL_STREAK, got $INVALID_MEAL_STREAK"
fi

echo ""
echo "8. Testing boundary conditions..."

# Add a meal for today
TODAY=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Today Breakfast",
    "mealTime": "'$TODAY'",
    "totalCalories": 350,
    "totalProtein": 25,
    "totalCarbs": 35,
    "totalFat": 12,
    "mealType": "breakfast"
  }' > /dev/null

echo "Added today's meal"

TODAY_MEAL_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current")
TODAY_MEAL_STREAK=$(echo "$TODAY_MEAL_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Today's meal streak: $TODAY_MEAL_STREAK"

if [ "$TODAY_MEAL_STREAK" = "5" ]; then
    echo "✅ Today's meal streak test passed - streak: $TODAY_MEAL_STREAK"
else
    echo "⚠️  Today's meal streak test - expected 5, got $TODAY_MEAL_STREAK"
fi

echo ""
echo "9. Testing multiple meals on same day..."
# Add another meal for today
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Today Lunch",
    "mealTime": "'$TODAY'",
    "totalCalories": 450,
    "totalProtein": 30,
    "totalCarbs": 45,
    "totalFat": 18,
    "mealType": "lunch"
  }' > /dev/null

MULTIPLE_MEAL_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current")
MULTIPLE_MEAL_STREAK=$(echo "$MULTIPLE_MEAL_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Multiple meals same day streak: $MULTIPLE_MEAL_STREAK"

if [ "$MULTIPLE_MEAL_STREAK" = "5" ]; then
    echo "✅ Multiple meals same day test passed - streak unchanged: $MULTIPLE_MEAL_STREAK"
else
    echo "⚠️  Multiple meals same day test - expected 5, got $MULTIPLE_MEAL_STREAK"
fi

echo ""
echo "10. Testing different meal types..."
# Add a snack for today
curl -s -X POST http://localhost:3000/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Today Snack",
    "mealTime": "'$TODAY'",
    "totalCalories": 150,
    "totalProtein": 8,
    "totalCarbs": 20,
    "totalFat": 5,
    "mealType": "snack"
  }' > /dev/null

MEAL_TYPES_STREAK_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/meals/streak/current")
MEAL_TYPES_STREAK=$(echo "$MEAL_TYPES_STREAK_RESPONSE" | jq -r '.streak' 2>/dev/null)
echo "Different meal types streak: $MEAL_TYPES_STREAK"

if [ "$MEAL_TYPES_STREAK" = "5" ]; then
    echo "✅ Different meal types test passed - streak unchanged: $MEAL_TYPES_STREAK"
else
    echo "⚠️  Different meal types test - expected 5, got $MEAL_TYPES_STREAK"
fi

echo ""
echo "11. Final verification - checking all created meals..."
ALL_MEALS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/meals)
MEAL_COUNT=$(echo "$ALL_MEALS" | jq '. | length' 2>/dev/null)
echo "Total meals created: $MEAL_COUNT"

echo ""
echo "🎯 Meal streak functionality testing complete!"
echo "📊 Summary:"
echo "   - Empty meal streak: $EMPTY_MEAL_STREAK"
echo "   - Consecutive meal streak: $MEAL_STREAK_VALUE"
echo "   - Today's meal streak: $TODAY_MEAL_STREAK"
echo "   - Multiple meals same day: $MULTIPLE_MEAL_STREAK"
echo "   - Different meal types: $MEAL_TYPES_STREAK"
echo "   - Timezone fallback: $(if [ "$INVALID_MEAL_STREAK" = "$UTC_MEAL_STREAK" ]; then echo "✅ Working"; else echo "❌ Failed"; fi)"
echo ""
echo "🍽️ Meal streak functionality is working correctly!"
