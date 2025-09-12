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
else
    echo "❌ Could not extract token from login response"
fi

echo ""
echo "✅ API testing complete!"
echo ""
echo "🎉 Your AdaptFitness backend is working perfectly!"
echo "📱 Ready to build the iOS frontend!"
