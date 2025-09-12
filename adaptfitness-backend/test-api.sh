#!/bin/bash

echo "🧪 Testing AdaptFitness API..."

BASE_URL="http://localhost:3000"

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s "$BASE_URL/health" | jq '.' || echo "❌ Health check failed"

echo -e "\n2. Testing welcome endpoint..."
curl -s "$BASE_URL/" | jq '.' || echo "❌ Welcome endpoint failed"

echo -e "\n3. Testing user registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }')

echo "$REGISTER_RESPONSE" | jq '.' || echo "❌ Registration failed"

echo -e "\n4. Testing user login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

echo "$LOGIN_RESPONSE" | jq '.' || echo "❌ Login failed"

# Extract token for protected endpoints
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo -e "\n5. Testing protected profile endpoint..."
    curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/auth/profile" | jq '.' || echo "❌ Profile endpoint failed"
    
    echo -e "\n6. Testing workouts endpoint..."
    curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/workouts" | jq '.' || echo "❌ Workouts endpoint failed"
    
    echo -e "\n7. Testing meals endpoint..."
    curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/meals" | jq '.' || echo "❌ Meals endpoint failed"
else
    echo "❌ Could not extract token from login response"
fi

echo -e "\n✅ API testing complete!"
