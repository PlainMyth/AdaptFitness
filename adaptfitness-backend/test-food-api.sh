#!/bin/bash

# Test script for OpenFoodFacts API integration
# Usage: ./test-food-api.sh

BASE_URL="http://localhost:3000"

echo "🧪 Testing OpenFoodFacts API Integration"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Get auth token
echo "📝 Step 1: Getting authentication token..."
echo ""

# Try to register a test user (ignore errors if user already exists)
echo "Attempting to register test user..."
REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testfood@example.com",
    "password": "TestPassword123!",
    "firstName": "Test",
    "lastName": "User",
    "dateOfBirth": "1990-01-01",
    "height": 175,
    "weight": 70,
    "gender": "male",
    "activityLevel": "moderate"
  }' 2>&1)

# Check if registration was successful (user created) or if user already exists
REGISTER_ERROR=$(echo "$REGISTER_RESPONSE" | grep -i "already exists\|conflict" || true)

# Always login to get the token (registration doesn't return a token)
echo "Logging in to get authentication token..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testfood@example.com",
    "password": "TestPassword123!"
  }' 2>&1)

# Extract token using jq if available, otherwise use grep/cut fallback
if command -v jq &> /dev/null; then
  TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.access_token // empty' 2>/dev/null)
else
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
fi

# Check if we got a valid token
if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo -e "${RED}❌ Failed to get authentication token${NC}"
  echo "Login Response: $LOGIN_RESPONSE"
  if [ -n "$REGISTER_ERROR" ]; then
    echo "Registration Response: $REGISTER_RESPONSE"
  fi
  exit 1
fi

echo -e "${GREEN}✅ Authentication successful${NC}"
echo ""

# Step 2: Test food search
echo "🔍 Step 2: Testing food search (query: 'apple')..."
echo ""

SEARCH_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals/foods/search?query=apple&page=1&pageSize=5" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json")

echo "$SEARCH_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$SEARCH_RESPONSE"
echo ""

if echo "$SEARCH_RESPONSE" | grep -q "foods"; then
  echo -e "${GREEN}✅ Food search successful${NC}"
  FOOD_COUNT=$(echo "$SEARCH_RESPONSE" | grep -o '"foods":\[' | wc -l)
  echo "   Found food items"
else
  echo -e "${RED}❌ Food search failed${NC}"
fi
echo ""

# Step 3: Test barcode lookup (using a common barcode)
echo "📦 Step 3: Testing barcode lookup (barcode: 3017620422003 - Nutella)..."
echo ""

BARCODE_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals/foods/barcode/3017620422003" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json")

echo "$BARCODE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$BARCODE_RESPONSE"
echo ""

if echo "$BARCODE_RESPONSE" | grep -q "id"; then
  echo -e "${GREEN}✅ Barcode lookup successful${NC}"
else
  echo -e "${YELLOW}⚠️  Barcode lookup may have failed (product might not exist in database)${NC}"
fi
echo ""

# Step 4: Test search with different query
echo "🔍 Step 4: Testing food search (query: 'chicken')..."
echo ""

CHICKEN_RESPONSE=$(curl -s -X GET "${BASE_URL}/meals/foods/search?query=chicken&page=1&pageSize=3" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json")

echo "$CHICKEN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CHICKEN_RESPONSE"
echo ""

if echo "$CHICKEN_RESPONSE" | grep -q "foods"; then
  echo -e "${GREEN}✅ Chicken search successful${NC}"
else
  echo -e "${RED}❌ Chicken search failed${NC}"
fi
echo ""

echo "========================================"
echo -e "${GREEN}✅ Testing complete!${NC}"
echo ""
echo "📱 Next Steps for iOS Testing:"
echo "   1. Make sure backend is running: npm run start:dev"
echo "   2. In Xcode simulator, use: http://localhost:3000"
echo "   3. Or use your Mac's IP: http://$(ipconfig getifaddr en0):3000"
echo ""

