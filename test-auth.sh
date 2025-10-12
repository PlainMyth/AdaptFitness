#!/bin/bash

# Simple Authentication Test Script
# This script helps you test user registration and login

BASE_URL="http://localhost:3000"
EMAIL="test@example.com"
PASSWORD="password123"

echo "🔐 Authentication Test Script"
echo "============================"
echo ""
echo "Base URL: $BASE_URL"
echo "Test Email: $EMAIL"
echo "Test Password: $PASSWORD"
echo ""

# Function to register user
register() {
    echo "📝 Registering user..."
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{
            "email": "'$EMAIL'",
            "password": "'$PASSWORD'",
            "firstName": "Test",
            "lastName": "User"
        }' \
        "$BASE_URL/auth/register" | jq '.'
}

# Function to login
login() {
    echo "🔑 Logging in..."
    RESPONSE=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{
            "email": "'$EMAIL'",
            "password": "'$PASSWORD'"
        }' \
        "$BASE_URL/auth/login")
    
    echo $RESPONSE | jq '.'
    
    # Extract token
    TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    
    if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
        echo ""
        echo "✅ Login successful!"
        echo "🔑 JWT Token: ${TOKEN:0:50}..."
        echo ""
        echo "You can now use this token for authenticated requests:"
        echo "curl -H \"Authorization: Bearer $TOKEN\" $BASE_URL/goal-calendar"
        return 0
    else
        echo "❌ Login failed!"
        return 1
    fi
}

# Function to test protected endpoint
test_protected() {
    echo "🔒 Testing protected endpoint..."
    
    # First try without token
    echo "Testing without token (should fail):"
    curl -s "$BASE_URL/goal-calendar" | jq '.'
    
    echo ""
    
    # Get token first
    RESPONSE=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{
            "email": "'$EMAIL'",
            "password": "'$PASSWORD'"
        }' \
        "$BASE_URL/auth/login")
    
    TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    
    if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
        echo "Testing with token (should succeed):"
        curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/goal-calendar" | jq '.'
    else
        echo "❌ Could not get token for protected endpoint test"
    fi
}

# Main menu
while true; do
    echo ""
    echo "Choose an option:"
    echo "1) Register new user"
    echo "2) Login"
    echo "3) Test protected endpoint"
    echo "4) Exit"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            register
            ;;
        2)
            login
            ;;
        3)
            test_protected
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1-4."
            ;;
    esac
done
