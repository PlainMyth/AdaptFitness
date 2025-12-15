# AI Workout Plan Generator - Testing Guide

## Overview

This guide provides instructions for testing the AI Workout Plan Generator endpoints using various tools (curl, Postman, HTTPie, etc.).

**Base URL**: `http://localhost:3000`

**Authentication**: All endpoints require JWT authentication (Bearer token)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Getting a JWT Token](#getting-a-jwt-token)
3. [Endpoint Testing](#endpoint-testing)
   - [Test API Connections](#1-test-api-connections)
   - [Generate Workout Plan](#2-generate-workout-plan)
   - [Search Exercises](#3-search-exercises)
   - [Get Exercise by ID](#4-get-exercise-by-id)
4. [Expected Responses](#expected-responses)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

1. **Server Running**: Ensure the backend is running on port 3000
   ```bash
   npm run start:dev
   ```

2. **Environment Variables**: Verify `.env` contains:
   ```env
   GEMINI_API_KEY=your_gemini_api_key
   EXERCISEDB_API_KEY=your_exercisedb_api_key
   ```

3. **User Account**: You need a registered user account to get a JWT token

---

## Getting a JWT Token

Before testing the AI endpoints, you need to authenticate and get a JWT token.

### Option 1: Register a New User

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe",
    "dateOfBirth": "1990-01-15",
    "gender": "male",
    "height": 175,
    "weight": 75
  }'
```

**Response** (contains JWT token):
```json
{
  "user": {
    "id": "user-uuid-here",
    "email": "test@example.com",
    "firstName": "John",
    "lastName": "Doe"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Option 2: Login with Existing User

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }'
```

**Save the token** for use in subsequent requests:
```bash
# In bash/zsh
export JWT_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## Endpoint Testing

### 1. Test API Connections

**Endpoint**: `GET /ai-workout-plans/test-connection`

**Purpose**: Verify that both Gemini AI and ExerciseDB APIs are accessible

**Request**:

```bash
# Using curl
curl -X GET http://localhost:3000/ai-workout-plans/test-connection \
  -H "Authorization: Bearer $JWT_TOKEN"

# Using HTTPie
http GET http://localhost:3000/ai-workout-plans/test-connection \
  "Authorization: Bearer $JWT_TOKEN"
```

**Expected Response**:
```json
{
  "gemini": {
    "success": true,
    "message": "Hello! I'm working and ready to help..."
  },
  "exerciseDb": {
    "success": true,
    "message": "API connection successful"
  }
}
```

**Status Code**: `200 OK`

---

### 2. Generate Workout Plan

**Endpoint**: `POST /ai-workout-plans/generate`

**Purpose**: Generate a personalized AI workout plan with exercise enrichment

**Request Body Parameters**:
- `userGoal` (required): One of `"build muscle"`, `"lose weight"`, `"improve endurance"`, `"general fitness"`
- `experienceLevel` (required): One of `"beginner"`, `"intermediate"`, `"advanced"`
- `daysPerWeek` (required): Integer between 3 and 7

#### Example 1: Beginner Muscle Building

```bash
curl -X POST http://localhost:3000/ai-workout-plans/generate \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userGoal": "build muscle",
    "experienceLevel": "beginner",
    "daysPerWeek": 3
  }'
```

#### Example 2: Advanced Endurance Training

```bash
curl -X POST http://localhost:3000/ai-workout-plans/generate \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userGoal": "improve endurance",
    "experienceLevel": "advanced",
    "daysPerWeek": 5
  }'
```

#### Example 3: Weight Loss (Intermediate)

```bash
curl -X POST http://localhost:3000/ai-workout-plans/generate \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userGoal": "lose weight",
    "experienceLevel": "intermediate",
    "daysPerWeek": 4
  }'
```

**Expected Response Structure**:
```json
{
  "success": true,
  "data": {
    "planName": "4-Day Weight Loss Circuit Training",
    "planDescription": "A comprehensive 4-day program...",
    "days": [
      {
        "dayNumber": 1,
        "dayName": "Full Body Circuit",
        "exercises": [
          {
            "exerciseName": "Bench Press",
            "sets": 3,
            "reps": "10-12",
            "exerciseDetails": {
              "exerciseId": "exercise-id-here",
              "name": "Bench Press",
              "imageUrl": "https://...",
              "videoUrl": "https://...",
              "bodyParts": ["CHEST"],
              "equipments": ["BARBELL"],
              "targetMuscles": ["PECTORALIS_MAJOR"],
              "instructions": ["Step 1...", "Step 2..."],
              "exerciseTips": ["Keep your back flat..."]
            },
            "dataSource": "exercisedb_api_detailed",
            "matchConfidence": "high",
            "searchStrategy": "direct"
          }
        ]
      }
    ]
  },
  "enrichmentStats": {
    "totalExercises": 20,
    "detailedEnriched": 18,
    "searchEnriched": 1,
    "aiOnly": 1,
    "totalEnriched": 19,
    "enrichmentRate": 95.0,
    "highConfidenceMatches": 18,
    "mediumConfidenceMatches": 1,
    "noMatches": 1,
    "highConfidenceRate": 90.0
  },
  "message": "Workout plan generated and enriched successfully"
}
```

**Status Codes**:
- `200 OK` - Plan generated successfully
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Missing or invalid JWT token
- `404 Not Found` - User not found
- `503 Service Unavailable` - Gemini AI service error

**Response Time**: Typically 10-30 seconds (depends on AI processing and exercise enrichment)

---

### 3. Search Exercises

**Endpoint**: `GET /ai-workout-plans/exercises/search?query={searchTerm}`

**Purpose**: Search for exercises in the ExerciseDB database

**Request**:

```bash
# Search for "push up"
curl -X GET "http://localhost:3000/ai-workout-plans/exercises/search?query=push%20up" \
  -H "Authorization: Bearer $JWT_TOKEN"

# Search for "squat"
curl -X GET "http://localhost:3000/ai-workout-plans/exercises/search?query=squat" \
  -H "Authorization: Bearer $JWT_TOKEN"

# Search for "bench press"
curl -X GET "http://localhost:3000/ai-workout-plans/exercises/search?query=bench%20press" \
  -H "Authorization: Bearer $JWT_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": [
    {
      "exerciseId": "exercise-uuid-1",
      "name": "Push-up",
      "imageUrl": "https://exercisedb-api1.p.rapidapi.com/..."
    },
    {
      "exerciseId": "exercise-uuid-2",
      "name": "Diamond Push-up",
      "imageUrl": "https://exercisedb-api1.p.rapidapi.com/..."
    }
  ],
  "message": "Search completed successfully"
}
```

**Status Codes**:
- `200 OK` - Search completed
- `400 Bad Request` - Missing query parameter
- `401 Unauthorized` - Missing or invalid JWT token

---

### 4. Get Exercise by ID

**Endpoint**: `GET /ai-workout-plans/exercises/:id`

**Purpose**: Get detailed information about a specific exercise

**Request**:

```bash
# Replace {exercise-id} with actual exercise ID from search results
curl -X GET http://localhost:3000/ai-workout-plans/exercises/{exercise-id} \
  -H "Authorization: Bearer $JWT_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "exerciseId": "exercise-uuid-here",
    "name": "Bench Press",
    "imageUrl": "https://...",
    "videoUrl": "https://...",
    "bodyParts": ["CHEST"],
    "equipments": ["BARBELL"],
    "exerciseType": "STRENGTH",
    "targetMuscles": ["PECTORALIS_MAJOR"],
    "secondaryMuscles": ["TRICEPS", "ANTERIOR_DELTOID"],
    "keywords": ["chest", "press", "barbell"],
    "overview": "The bench press is a fundamental...",
    "instructions": [
      "Lie flat on the bench with feet planted firmly on the ground",
      "Grip the barbell slightly wider than shoulder width",
      "Lower the bar to your chest in a controlled manner",
      "Press the bar back up to starting position"
    ],
    "exerciseTips": [
      "Keep your back flat against the bench",
      "Don't bounce the bar off your chest",
      "Breathe out as you press up"
    ],
    "variations": ["Incline Bench Press", "Decline Bench Press"],
    "relatedExerciseIds": ["exercise-uuid-2", "exercise-uuid-3"]
  },
  "message": "Exercise details retrieved successfully"
}
```

**Status Codes**:
- `200 OK` - Exercise found
- `400 Bad Request` - Invalid exercise ID
- `401 Unauthorized` - Missing or invalid JWT token
- `404 Not Found` - Exercise not found

---

## Expected Responses

### Success Response (200 OK)

All successful responses follow this general structure:

```json
{
  "success": true,
  "data": { /* endpoint-specific data */ },
  "message": "Success message"
}
```

### Error Responses

#### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Invalid userGoal. Must be one of: build muscle, lose weight, improve endurance, general fitness",
  "error": "Bad Request"
}
```

#### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

#### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "User with ID {userId} not found",
  "error": "Not Found"
}
```

#### 503 Service Unavailable
```json
{
  "statusCode": 503,
  "message": "AI service temporarily unavailable. Please try again later.",
  "error": "Service Unavailable"
}
```

---

## Postman Collection

### Import This Collection

Create a new Postman collection with these requests:

1. **Environment Variables**:
   - `BASE_URL`: `http://localhost:3000`
   - `JWT_TOKEN`: (set after login)

2. **Pre-request Script** (for all requests):
   ```javascript
   pm.request.headers.add({
     key: 'Authorization',
     value: 'Bearer ' + pm.environment.get('JWT_TOKEN')
   });
   ```

3. **Requests**:
   - `POST {{BASE_URL}}/auth/register` - Register User
   - `POST {{BASE_URL}}/auth/login` - Login User
   - `GET {{BASE_URL}}/ai-workout-plans/test-connection` - Test Connection
   - `POST {{BASE_URL}}/ai-workout-plans/generate` - Generate Plan
   - `GET {{BASE_URL}}/ai-workout-plans/exercises/search?query=squat` - Search Exercises
   - `GET {{BASE_URL}}/ai-workout-plans/exercises/:id` - Get Exercise

---

## Troubleshooting

### Issue: "Unauthorized" Error

**Cause**: Missing or invalid JWT token

**Solution**:
1. Verify you're logged in: `POST /auth/login`
2. Check token is included in Authorization header: `Authorization: Bearer {token}`
3. Ensure token hasn't expired (default: 24 hours)

---

### Issue: "AI service temporarily unavailable"

**Cause**: Gemini API error or timeout

**Solution**:
1. Check `GEMINI_API_KEY` is set correctly in `.env`
2. Verify API key is valid and has quota remaining
3. Test connection: `GET /ai-workout-plans/test-connection`
4. Check server logs for detailed error messages

---

### Issue: Low Enrichment Rate (<50%)

**Cause**: ExerciseDB API issues or exercise names too generic

**Solution**:
1. Check `EXERCISEDB_API_KEY` is valid
2. Test connection: `GET /ai-workout-plans/test-connection`
3. Review enrichment stats in response
4. Check server logs for search strategy details

---

### Issue: "User not found"

**Cause**: Invalid user ID in JWT token

**Solution**:
1. Re-login to get fresh JWT token
2. Verify user exists in database
3. Check JWT_SECRET matches between registration and validation

---

### Issue: Validation Errors

**Common validation errors**:

```json
{
  "statusCode": 400,
  "message": [
    "userGoal must be one of the following values: build muscle, lose weight, improve endurance, general fitness",
    "daysPerWeek must not be less than 3",
    "daysPerWeek must not be greater than 7"
  ],
  "error": "Bad Request"
}
```

**Solution**: Ensure request body matches DTO requirements:
- `userGoal`: exact string match (lowercase)
- `experienceLevel`: exact string match (lowercase)
- `daysPerWeek`: number between 3-7

---

## Performance Notes

### Expected Response Times

- **Test Connection**: <1 second
- **Generate Workout Plan**: 10-30 seconds
  - Gemini AI generation: 5-15 seconds
  - Exercise enrichment: 5-15 seconds (depends on number of exercises)
- **Search Exercises**: 1-3 seconds
- **Get Exercise by ID**: <1 second

### Rate Limiting

All endpoints are protected by global rate limiting (configured in `throttler.config.ts`).

**Default limits**:
- Development: 100 requests per minute
- Production: 10 requests per minute

**Rate limit exceeded response**:
```json
{
  "statusCode": 429,
  "message": "ThrottlerException: Too Many Requests"
}
```

---

## Example Testing Script

Save this as `test-ai-endpoints.sh`:

```bash
#!/bin/bash

# Configuration
BASE_URL="http://localhost:3000"
EMAIL="test@example.com"
PASSWORD="SecurePass123!"

echo "🚀 Testing AI Workout Plan Generator Endpoints"
echo "=============================================="

# 1. Login
echo -e "\n1️⃣  Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

JWT_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')

if [ "$JWT_TOKEN" = "null" ]; then
  echo "❌ Login failed. Please check credentials."
  exit 1
fi

echo "✅ Login successful"

# 2. Test Connection
echo -e "\n2️⃣  Testing API connections..."
curl -s -X GET $BASE_URL/ai-workout-plans/test-connection \
  -H "Authorization: Bearer $JWT_TOKEN" | jq

# 3. Search Exercises
echo -e "\n3️⃣  Searching for exercises (squat)..."
curl -s -X GET "$BASE_URL/ai-workout-plans/exercises/search?query=squat" \
  -H "Authorization: Bearer $JWT_TOKEN" | jq '.data[0:3]'

# 4. Generate Workout Plan
echo -e "\n4️⃣  Generating workout plan (this may take 10-30 seconds)..."
curl -s -X POST $BASE_URL/ai-workout-plans/generate \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userGoal": "build muscle",
    "experienceLevel": "beginner",
    "daysPerWeek": 3
  }' | jq '{success, message, enrichmentStats}'

echo -e "\n✅ All tests completed!"
```

**Run it**:
```bash
chmod +x test-ai-endpoints.sh
./test-ai-endpoints.sh
```

---

## Additional Resources

- **API Documentation**: See `CODE_DOCUMENTATION.md` in project root
- **Architecture**: See `/Users/ivanflores/.claude/plans/shiny-tumbling-eagle.md`
- **Python Reference**: Original Python implementation in `ai-api/` directory
- **Server Logs**: Check console output for detailed debugging info

---

## Support

If you encounter issues:

1. **Check server logs** for detailed error messages
2. **Verify environment variables** in `.env`
3. **Test API connections** using the test-connection endpoint
4. **Review enrichment stats** to identify exercise matching issues
5. **Check network connectivity** to Gemini AI and ExerciseDB APIs

Happy testing! 🏋️‍♂️
