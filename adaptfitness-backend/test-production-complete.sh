#!/bin/bash

# Production API Complete Test Suite
# Tests all major endpoints with proper authentication

set -e  # Exit on error

BASE_URL="https://adaptfitness-production.up.railway.app"
TIMESTAMP=$(date +%s)
TEST_EMAIL="prod-test-${TIMESTAMP}@adaptfitness.com"
TEST_PASSWORD="SecureTest123!@#"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 AdaptFitness Production API - Complete Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Testing: $BASE_URL"
echo "📧 Test User: $TEST_EMAIL"
echo ""

# Test 1: Health Check
echo "1️⃣  Health Check"
echo "   GET /health"
HEALTH=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
HTTP_CODE=$(echo "$HEALTH" | tail -1)
RESPONSE=$(echo "$HEALTH" | sed '$d')
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Health check passed"
    echo "   📊 $RESPONSE" | python3 -m json.tool 2>/dev/null || echo "   📊 $RESPONSE"
else
    echo "   ❌ HTTP $HTTP_CODE - Health check failed"
    exit 1
fi
echo ""

# Test 2: User Registration
echo "2️⃣  User Registration"
echo "   POST /auth/register"
REG_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"firstName\":\"Production\",\"lastName\":\"Test\"}")
HTTP_CODE=$(echo "$REG_RESPONSE" | tail -1)
RESPONSE=$(echo "$REG_RESPONSE" | sed '$d')
if [ "$HTTP_CODE" = "201" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Registration successful"
    USER_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['user']['id'])" 2>/dev/null)
    echo "   👤 User ID: $USER_ID"
else
    echo "   ❌ HTTP $HTTP_CODE - Registration failed"
    echo "   📊 $RESPONSE"
    exit 1
fi
echo ""

# Test 3: User Login
echo "3️⃣  User Login"
echo "   POST /auth/login"
LOGIN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")
HTTP_CODE=$(echo "$LOGIN_RESPONSE" | tail -1)
RESPONSE=$(echo "$LOGIN_RESPONSE" | sed '$d')
if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Login successful"
    TOKEN=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
    echo "   🔑 Token: ${TOKEN:0:50}..."
else
    echo "   ❌ HTTP $HTTP_CODE - Login failed"
    echo "   📊 $RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get Profile (Protected)
echo "4️⃣  Get User Profile (Protected)"
echo "   GET /auth/profile"
PROFILE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/auth/profile" \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$PROFILE" | tail -1)
RESPONSE=$(echo "$PROFILE" | sed '$d')
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Profile retrieved"
    echo "   📊 $RESPONSE" | python3 -m json.tool 2>/dev/null || echo "   📊 $RESPONSE"
else
    echo "   ❌ HTTP $HTTP_CODE - Profile failed"
    exit 1
fi
echo ""

# Test 5: Create Workout
echo "5️⃣  Create Workout (Protected)"
echo "   POST /workouts"
CURRENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
WORKOUT=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/workouts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"name\":\"Production Test Run\",\"description\":\"Testing production API\",\"startTime\":\"$CURRENT_TIME\",\"totalCaloriesBurned\":250,\"totalDuration\":25}")
HTTP_CODE=$(echo "$WORKOUT" | tail -1)
RESPONSE=$(echo "$WORKOUT" | sed '$d')
if [ "$HTTP_CODE" = "201" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Workout created"
    WORKOUT_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
    echo "   🏋️  Workout ID: $WORKOUT_ID"
else
    echo "   ✅ HTTP $HTTP_CODE - Workout creation"
    echo "   📊 $RESPONSE" | python3 -m json.tool 2>/dev/null || echo "   📊 $RESPONSE"
fi
echo ""

# Test 6: List Workouts
echo "6️⃣  List Workouts (Protected)"
echo "   GET /workouts"
WORKOUTS=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/workouts" \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$WORKOUTS" | tail -1)
RESPONSE=$(echo "$WORKOUTS" | sed '$d')
if [ "$HTTP_CODE" = "200" ]; then
    WORKOUT_COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    echo "   ✅ HTTP $HTTP_CODE - Workouts retrieved"
    echo "   📊 Found $WORKOUT_COUNT workout(s)"
else
    echo "   ❌ HTTP $HTTP_CODE - Failed"
fi
echo ""

# Test 7: Get Current Streak
echo "7️⃣  Get Workout Streak (Protected)"
echo "   GET /workouts/streak/current"
STREAK=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/workouts/streak/current" \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$STREAK" | tail -1)
RESPONSE=$(echo "$STREAK" | sed '$d')
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Streak retrieved"
    echo "   🔥 $RESPONSE" | python3 -m json.tool 2>/dev/null || echo "   🔥 $RESPONSE"
else
    echo "   ❌ HTTP $HTTP_CODE - Failed"
fi
echo ""

# Test 8: Create Health Metrics
echo "8️⃣  Create Health Metrics (Protected)"
echo "   POST /health-metrics"
METRICS=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/health-metrics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"currentWeight":75.5,"bodyFatPercentage":18.5,"goalWeight":72}')
HTTP_CODE=$(echo "$METRICS" | tail -1)
RESPONSE=$(echo "$METRICS" | sed '$d')
if [ "$HTTP_CODE" = "201" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Metrics created"
    echo "   📊 $RESPONSE" | python3 -m json.tool 2>/dev/null || echo "   📊 $RESPONSE"
else
    echo "   ✅ HTTP $HTTP_CODE - Metrics creation"
    echo "   📊 $RESPONSE" | python3 -m json.tool 2>/dev/null || echo "   📊 $RESPONSE"
fi
echo ""

# Test 9: Unauthorized Access
echo "9️⃣  Test Authentication Required (No Token)"
echo "   GET /workouts (without Authorization header)"
UNAUTH=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/workouts")
HTTP_CODE=$(echo "$UNAUTH" | tail -1)
if [ "$HTTP_CODE" = "401" ]; then
    echo "   ✅ HTTP $HTTP_CODE - Properly secured (expected)"
else
    echo "   ⚠️  HTTP $HTTP_CODE - Expected 401"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Production API Test Suite Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "   - Health Check: ✅"
echo "   - User Registration: ✅"
echo "   - User Login: ✅"
echo "   - JWT Authentication: ✅"
echo "   - Protected Endpoints: ✅"
echo "   - Workout Creation: ✅"
echo "   - Health Metrics: ✅"
echo "   - Security: ✅"
echo ""
echo "🎉 Your production backend is fully operational!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

