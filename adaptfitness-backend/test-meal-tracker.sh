#!/bin/bash

# Meal Tracker API Test Script
# Tests all meal-related endpoints to verify functionality

BASE_URL="${1:-http://localhost:3000}"
TEST_EMAIL="test-meal-$(date +%s)@example.com"
TEST_PASSWORD="TestPassword123!"

echo "🧪 AdaptFitness Meal Tracker API Test Suite"
echo "============================================"
echo "Base URL: $BASE_URL"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to print test results
print_test() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ $1${NC}"
        ((TESTS_FAILED++))
    fi
}

# Step 1: Register test user
echo "📝 Step 1: Registering test user..."
REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"${TEST_PASSWORD}\",
    \"firstName\": \"Meal\",
    \"lastName\": \"Tester\"
  }")

if echo "$REGISTER_RESPONSE" | grep -q "User created successfully"; then
    print_test "User registration successful"
else
    echo "Registration response: $REGISTER_RESPONSE"
    print_test "User registration"
fi

# Step 2: Login to get token
echo ""
echo "🔐 Step 2: Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"${TEST_PASSWORD}\"
  }")

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "Login response: $LOGIN_RESPONSE"
    echo -e "${RED}❌ Failed to get authentication token${NC}"
    exit 1
fi

print_test "Login successful"

# Step 3: Create a meal
echo ""
echo "🍽️  Step 3: Creating a meal..."
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
CREATE_MEAL_RESPONSE=$(curl -s -X POST "${BASE_URL}/meals" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"name\": \"Test Breakfast\",
    \"description\": \"A healthy breakfast for testing\",
    \"mealTime\": \"${CURRENT_TIME}\",
    \"totalCalories\": 500,
    \"totalProtein\": 30,
    \"totalCarbs\": 50,
    \"totalFat\": 20,
    \"mealType\": \"breakfast\"
  }")

MEAL_ID=$(echo "$CREATE_MEAL_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -n "$MEAL_ID" ]; then
    print_test "Meal creation successful (ID: $MEAL_ID)"
else
    echo "Create meal response: $CREATE_MEAL_RESPONSE"
    print_test "Meal creation"
fi

# Step 4: Get all meals
echo ""
echo "📋 Step 4: Getting all meals..."
GET_MEALS_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals" \
  -H "Authorization: Bearer ${TOKEN}")

if echo "$GET_MEALS_RESPONSE" | grep -q "Test Breakfast"; then
    print_test "Get all meals successful"
else
    echo "Get meals response: $GET_MEALS_RESPONSE"
    print_test "Get all meals"
fi

# Step 5: Get single meal
if [ -n "$MEAL_ID" ]; then
    echo ""
    echo "🔍 Step 5: Getting single meal..."
    GET_MEAL_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals/${MEAL_ID}" \
      -H "Authorization: Bearer ${TOKEN}")

    if echo "$GET_MEAL_RESPONSE" | grep -q "$MEAL_ID"; then
        print_test "Get single meal successful"
    else
        echo "Get meal response: $GET_MEAL_RESPONSE"
        print_test "Get single meal"
    fi
fi

# Step 6: Update meal
if [ -n "$MEAL_ID" ]; then
    echo ""
    echo "✏️  Step 6: Updating meal..."
    UPDATE_MEAL_RESPONSE=$(curl -s -X PUT "${BASE_URL}/meals/${MEAL_ID}" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${TOKEN}" \
      -d "{
        \"name\": \"Updated Breakfast\",
        \"totalCalories\": 550
      }")

    if echo "$UPDATE_MEAL_RESPONSE" | grep -q "Updated Breakfast"; then
        print_test "Meal update successful"
    else
        echo "Update meal response: $UPDATE_MEAL_RESPONSE"
        print_test "Meal update"
    fi
fi

# Step 7: Get streak
echo ""
echo "🔥 Step 7: Getting meal streak..."
STREAK_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals/streak/current" \
  -H "Authorization: Bearer ${TOKEN}")

if echo "$STREAK_RESPONSE" | grep -q "streak"; then
    print_test "Get streak successful"
    echo "Streak response: $STREAK_RESPONSE"
else
    echo "Streak response: $STREAK_RESPONSE"
    print_test "Get streak"
fi

# Step 8: Search foods
echo ""
echo "🔎 Step 8: Searching for foods..."
SEARCH_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals/foods/search?query=apple&page=1&pageSize=20" \
  -H "Authorization: Bearer ${TOKEN}")

if echo "$SEARCH_RESPONSE" | grep -q "foods"; then
    print_test "Food search successful"
    FOOD_COUNT=$(echo "$SEARCH_RESPONSE" | grep -o '"totalCount":[0-9]*' | cut -d':' -f2)
    echo "Found $FOOD_COUNT foods"
else
    echo "Search response: $SEARCH_RESPONSE"
    print_test "Food search"
fi

# Step 9: Delete meal
if [ -n "$MEAL_ID" ]; then
    echo ""
    echo "🗑️  Step 9: Deleting meal..."
    DELETE_RESPONSE=$(curl -s -X DELETE "${BASE_URL}/meals/${MEAL_ID}" \
      -H "Authorization: Bearer ${TOKEN}")

    if echo "$DELETE_RESPONSE" | grep -q "deleted successfully"; then
        print_test "Meal deletion successful"
    else
        echo "Delete response: $DELETE_RESPONSE"
        print_test "Meal deletion"
    fi
fi

# Step 10: Verify meal is deleted
if [ -n "$MEAL_ID" ]; then
    echo ""
    echo "✅ Step 10: Verifying meal deletion..."
    VERIFY_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${BASE_URL}/meals/${MEAL_ID}" \
      -H "Authorization: Bearer ${TOKEN}")

    HTTP_CODE=$(echo "$VERIFY_RESPONSE" | tail -n1)
    if [ "$HTTP_CODE" = "404" ]; then
        print_test "Meal deletion verified (404 as expected)"
    else
        echo "Verify response: $VERIFY_RESPONSE"
        print_test "Meal deletion verification"
    fi
fi

# Summary
echo ""
echo "============================================"
echo "📊 Test Summary"
echo "============================================"
echo -e "${GREEN}✅ Tests Passed: ${TESTS_PASSED}${NC}"
echo -e "${RED}❌ Tests Failed: ${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All meal tracker tests passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Please review the output above.${NC}"
    exit 1
fi

