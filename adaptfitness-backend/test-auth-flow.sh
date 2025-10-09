#!/bin/bash

# AdaptFitness Backend - Authentication Flow Testing Script
# 
# This script tests the complete authentication flow including:
# - User registration with strong and weak passwords
# - Login with valid and invalid credentials  
# - Protected endpoint access with and without tokens
#
# Usage: ./test-auth-flow.sh
# Requires: Backend server running on http://localhost:3000

# Note: We don't use set -e to allow tests to continue even if one fails

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_URL="${API_URL:-http://localhost:3000}"
TEST_EMAIL="test.$(date +%s)@example.com"
TEST_PASSWORD="SecurePass123!"
WEAK_PASSWORD="weak"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_test() {
    echo -e "\n${YELLOW}TEST $TESTS_RUN: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

print_failure() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}INFO${NC}: $1"
}

# Test functions
test_health_check() {
    ((TESTS_RUN++))
    print_test "Health check endpoint"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/health")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Health check returned 200"
        print_info "Response: $BODY"
    else
        print_failure "Health check failed with code $HTTP_CODE"
        exit 1
    fi
}

test_register_with_weak_password() {
    ((TESTS_RUN++))
    print_test "Registration with weak password (should fail)"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"weak.$(date +%s)@example.com\",
            \"password\": \"$WEAK_PASSWORD\",
            \"firstName\": \"Weak\",
            \"lastName\": \"Password\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "400" ]; then
        print_success "Weak password rejected with 400 Bad Request"
        print_info "Error message: $(echo "$BODY" | grep -o '"message":"[^"]*"' || echo "N/A")"
    else
        print_failure "Expected 400 but got $HTTP_CODE"
    fi
}

test_register_with_strong_password() {
    ((TESTS_RUN++))
    print_test "Registration with strong password (should succeed)"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"$TEST_PASSWORD\",
            \"firstName\": \"Test\",
            \"lastName\": \"User\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
        print_success "Registration successful with code $HTTP_CODE"
        print_info "Response: $(echo "$BODY" | head -c 100)..."
    else
        print_failure "Registration failed with code $HTTP_CODE"
        print_info "Response: $BODY"
    fi
}

test_duplicate_registration() {
    ((TESTS_RUN++))
    print_test "Duplicate registration (should fail)"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"$TEST_PASSWORD\",
            \"firstName\": \"Test\",
            \"lastName\": \"User\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" = "409" ] || [ "$HTTP_CODE" = "400" ]; then
        print_success "Duplicate registration rejected with code $HTTP_CODE"
    else
        print_failure "Expected 409/400 but got $HTTP_CODE"
    fi
}

test_login_with_invalid_credentials() {
    ((TESTS_RUN++))
    print_test "Login with invalid credentials (should fail)"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"WrongPassword123!\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        print_success "Invalid credentials rejected with 401 Unauthorized"
    else
        print_failure "Expected 401 but got $HTTP_CODE"
    fi
}

test_login_with_valid_credentials() {
    ((TESTS_RUN++))
    print_test "Login with valid credentials (should succeed)"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"$TEST_PASSWORD\"
        }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "Login successful with code $HTTP_CODE"
        
        # Extract access token
        ACCESS_TOKEN=$(echo "$BODY" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$ACCESS_TOKEN" ]; then
            print_info "Access token received: ${ACCESS_TOKEN:0:20}..."
            echo "$ACCESS_TOKEN" > /tmp/adaptfitness_test_token.txt
        else
            print_failure "No access token in response"
        fi
    else
        print_failure "Login failed with code $HTTP_CODE"
    fi
}

test_protected_endpoint_without_token() {
    ((TESTS_RUN++))
    print_test "Access protected endpoint without token (should fail)"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/auth/profile")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        print_success "Protected endpoint rejected request without token (401)"
    else
        print_failure "Expected 401 but got $HTTP_CODE"
    fi
}

test_protected_endpoint_with_token() {
    ((TESTS_RUN++))
    print_test "Access protected endpoint with valid token (should succeed)"
    
    if [ ! -f /tmp/adaptfitness_test_token.txt ]; then
        print_failure "No access token available from previous test"
        return
    fi
    
    ACCESS_TOKEN=$(cat /tmp/adaptfitness_test_token.txt)
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/auth/profile" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Protected endpoint accessed successfully"
        print_info "Profile: $(echo "$BODY" | head -c 100)..."
    else
        print_failure "Expected 200 but got $HTTP_CODE"
    fi
}

test_password_requirements() {
    ((TESTS_RUN++))
    print_test "Test various password requirement violations"
    
    local test_cases=(
        "short:Short1!:too short"
        "no-upper:lowercase123!:no uppercase"
        "no-lower:UPPERCASE123!:no lowercase"
        "no-number:NoNumbers!:no number"
        "no-special:NoSpecial123:no special char"
    )
    
    local sub_pass=0
    local sub_fail=0
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r name password reason <<< "$test_case"
        
        RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/register" \
            -H "Content-Type: application/json" \
            -d "{
                \"email\": \"${name}.$(date +%s)@example.com\",
                \"password\": \"$password\",
                \"firstName\": \"Test\",
                \"lastName\": \"User\"
            }")
        
        HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
        
        if [ "$HTTP_CODE" = "400" ]; then
            ((sub_pass++))
            print_info "  ✓ Rejected: $reason"
        else
            ((sub_fail++))
            print_info "  ✗ Not rejected: $reason (got $HTTP_CODE)"
        fi
    done
    
    if [ $sub_fail -eq 0 ]; then
        print_success "All password requirement tests passed ($sub_pass/5)"
    else
        print_failure "Some password tests failed (passed: $sub_pass, failed: $sub_fail)"
    fi
}

# Main execution
print_header "AdaptFitness Authentication Flow Tests"
print_info "API URL: $API_URL"
print_info "Test Email: $TEST_EMAIL"

# Run all tests
test_health_check
test_register_with_weak_password
test_register_with_strong_password
test_duplicate_registration
test_login_with_invalid_credentials
test_login_with_valid_credentials
test_protected_endpoint_without_token
test_protected_endpoint_with_token
test_password_requirements

# Summary
print_header "Test Summary"
echo -e "Total Tests: ${BLUE}$TESTS_RUN${NC}"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

# Clean up
rm -f /tmp/adaptfitness_test_token.txt

# Exit code
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed! ✗${NC}"
    exit 1
fi
