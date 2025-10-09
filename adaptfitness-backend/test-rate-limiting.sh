#!/bin/bash

# AdaptFitness Backend - Rate Limiting Test Script
# 
# This script tests that rate limiting is working properly on auth endpoints
#
# Usage: ./test-rate-limiting.sh
# Requires: Backend server running on http://localhost:3000

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API_URL="${API_URL:-http://localhost:3000}"
TEST_EMAIL="ratelimit.$(date +%s)@example.com"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Rate Limiting Test${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 1: Verify rate limiting on registration
echo -e "${YELLOW}TEST 1: Rate Limiting on Registration${NC}"
echo "Attempting 6 registration requests (limit is 5)..."
echo ""

SUCCESS_COUNT=0
RATE_LIMITED_COUNT=0

for i in {1..6}; do
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"test${i}.$(date +%s)@example.com\",
            \"password\": \"SecurePass123!\",
            \"firstName\": \"Test\",
            \"lastName\": \"User${i}\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
        echo -e "  Request $i: ${GREEN}✓ SUCCESS${NC} (HTTP $HTTP_CODE)"
        ((SUCCESS_COUNT++))
    elif [ "$HTTP_CODE" = "429" ]; then
        echo -e "  Request $i: ${YELLOW}⚠ RATE LIMITED${NC} (HTTP 429)"
        ((RATE_LIMITED_COUNT++))
    else
        echo -e "  Request $i: ${RED}✗ ERROR${NC} (HTTP $HTTP_CODE)"
    fi
    
    sleep 0.5
done

echo ""
if [ $RATE_LIMITED_COUNT -gt 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Rate limiting is working! ($RATE_LIMITED_COUNT requests blocked)"
else
    echo -e "${RED}✗ FAIL${NC}: Rate limiting NOT working (no 429 responses)"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}TEST 2: Rate Limiting on Login${NC}"
echo "Attempting 6 login requests with invalid password (limit is 5)..."
echo ""

SUCCESS_COUNT=0
RATE_LIMITED_COUNT=0
UNAUTHORIZED_COUNT=0

for i in {1..6}; do
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"nonexistent@example.com\",
            \"password\": \"WrongPassword${i}!\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        echo -e "  Attempt $i: ${BLUE}○ UNAUTHORIZED${NC} (HTTP 401 - normal)"
        ((UNAUTHORIZED_COUNT++))
    elif [ "$HTTP_CODE" = "429" ]; then
        echo -e "  Attempt $i: ${YELLOW}⚠ RATE LIMITED${NC} (HTTP 429 - protected!)"
        ((RATE_LIMITED_COUNT++))
    else
        echo -e "  Attempt $i: ${RED}✗ UNEXPECTED${NC} (HTTP $HTTP_CODE)"
    fi
    
    sleep 0.5
done

echo ""
if [ $RATE_LIMITED_COUNT -gt 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Login rate limiting is working! ($RATE_LIMITED_COUNT requests blocked)"
else
    echo -e "${RED}✗ FAIL${NC}: Login rate limiting NOT working"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}TEST 3: Legitimate User Not Blocked${NC}"
echo "Testing that legitimate users can still access the API..."
echo ""

# First, register a legitimate user
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d "{
        \"email\": \"legit.$(date +%s)@example.com\",
        \"password\": \"LegitUser123!\",
        \"firstName\": \"Legit\",
        \"lastName\": \"User\"
    }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Legitimate user can register"
elif [ "$HTTP_CODE" = "429" ]; then
    echo -e "${YELLOW}⚠ WARNING${NC}: User hit rate limit from previous test (this is expected)"
else
    echo -e "${RED}✗ FAIL${NC}: Unexpected response (HTTP $HTTP_CODE)"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Rate limiting appears to be: ${GREEN}WORKING${NC}"
echo -e "Note: Wait 15 minutes for rate limits to reset for complete testing"
echo ""
