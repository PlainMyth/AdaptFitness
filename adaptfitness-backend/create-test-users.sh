#!/bin/bash
# Create test user accounts

API_URL="${API_URL:-http://localhost:3000}"

echo "Creating test user accounts..."

curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser1@adaptfitness.dev","password":"TestUser1Pass!","firstName":"Test","lastName":"User1"}' \
  > /dev/null && echo "testuser1@adaptfitness.dev created"

curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser2@adaptfitness.dev","password":"TestUser2Pass!","firstName":"Test","lastName":"User2"}' \
  > /dev/null && echo "testuser2@adaptfitness.dev created"

curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"edgecase@adaptfitness.dev","password":"EdgeCase123!","firstName":"Edge","lastName":"Case"}' \
  > /dev/null && echo "edgecase@adaptfitness.dev created"

curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@adaptfitness.dev","password":"DevAccount123!","firstName":"Dev","lastName":"Account"}' \
  > /dev/null && echo "dev@adaptfitness.dev created"

echo "Done"
