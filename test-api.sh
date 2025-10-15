#!/bin/bash

echo "🚗 Testing AutoTrader API..."
echo "================================"

BASE_URL="http://localhost:8080/api/v1/cars"

# Test Health Check
echo "1. Testing Health Check..."
curl -s "$BASE_URL/health" | jq '.' 2>/dev/null || curl -s "$BASE_URL/health"
echo -e "\n"

# Test Get All Cars
echo "2. Testing Get All Cars..."
curl -s "$BASE_URL?page=0&size=3" | jq '.' 2>/dev/null || curl -s "$BASE_URL?page=0&size=3"
echo -e "\n"

# Test Get Cars by Brand
echo "3. Testing Get Cars by Brand (Toyota)..."
curl -s "$BASE_URL/brand/Toyota" | jq '.' 2>/dev/null || curl -s "$BASE_URL/brand/Toyota"
echo -e "\n"

# Test Get Cars by Price Range
echo "4. Testing Get Cars by Price Range (300M - 500M)..."
curl -s "$BASE_URL/price-range?minPrice=300000000&maxPrice=500000000" | jq '.' 2>/dev/null || curl -s "$BASE_URL/price-range?minPrice=300000000&maxPrice=500000000"
echo -e "\n"

echo "✅ API Testing completed!"
echo ""
echo "📝 Available endpoints:"
echo "- GET $BASE_URL/health"
echo "- GET $BASE_URL?page=0&size=10"
echo "- GET $BASE_URL/brand/{brand}"
echo "- GET $BASE_URL/price-range?minPrice={min}&maxPrice={max}"
