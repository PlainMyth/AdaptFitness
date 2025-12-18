#!/bin/bash

echo " Running Gemini Feature Tests"

# Backend URL
BASE_URL="http://localhost:3000/gemini"

# Test 1: Valid POST request
echo -e "\nTest 1: Valid POST request"
VALID_PAYLOAD='{"prompt":"Generate a simple workout plan"}'
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL -H "Content-Type: application/json" -d "$VALID_PAYLOAD")
if [ "$RESPONSE" -eq 201 ]; then
  echo " Passed: Valid request accepted"
else
  echo " Failed: Valid request not accepted, status code $RESPONSE"
fi

# Test 2: Invalid POST request (missing prompt)
echo -e "\nTest 2: Invalid POST request (missing prompt)"
INVALID_PAYLOAD='{}'
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL -H "Content-Type: application/json" -d "$INVALID_PAYLOAD")
if [ "$RESPONSE" -eq 400 ]; then
  echo " Passed: Missing data correctly rejected"
else
  echo " Failed: Missing data not rejected, status code $RESPONSE"
fi

# Test 3: Edge case POST request (special characters)
echo -e "\nTest 3: Edge case POST request (special characters)"
EDGE_PAYLOAD='{"prompt":"!@#$%^&*()_+-=[]{}|;:\'"'"'",.<>?/"}'
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL -H "Content-Type: application/json" -d "$EDGE_PAYLOAD")
if [ "$RESPONSE" -eq 400 ]; then
  echo " Passed: Special characters correctly rejected"
else
  echo " Failed: Special characters test, status code $RESPONSE"
fi


echo -e "\nAll Gemini tests complete"

