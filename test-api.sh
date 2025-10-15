#!/bin/bash

echo "🚗 Testing AutoTrader API..."
echo "================================"

BASE_URL="http://localhost:8080/api/v1/cars"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function to test API endpoint
test_endpoint() {
    local test_name="$1"
    local url="$2"
    local expected_status="${3:-200}"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    echo "URL: $url"
    
    # Make request and capture response
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$url")
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    # Check if jq is available for pretty printing
    if command -v jq &> /dev/null; then
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo "$body"
    fi
    
    # Check status code
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ Status: $http_code (Expected: $expected_status)${NC}"
    else
        echo -e "${RED}❌ Status: $http_code (Expected: $expected_status)${NC}"
    fi
    echo -e "\n"
}

# Test 1: Health Check
test_endpoint "Health Check" "$BASE_URL/health"

# Test 2: Search Cars - Basic (no filters)
test_endpoint "Search Cars - Basic" "$BASE_URL/search?page=0&size=5"

# Test 3: Search Cars - With Text Search
test_endpoint "Search Cars - Text Search (Toyota)" "$BASE_URL/search?value=Toyota&page=0&size=3"

# Test 4: Search Cars - Price Range
test_endpoint "Search Cars - Price Range (10M - 50M)" "$BASE_URL/search?minPrice=10000000&maxPrice=50000000&page=0&size=3"

# Test 5: Search Cars - Multiple Filters
test_endpoint "Search Cars - Multiple Filters" "$BASE_URL/search?selectedMakes=Toyota,Honda&selectedBodyTypes=SUV,Sedan&sort=price-asc&page=0&size=3"

# Test 6: Search Cars - Invalid Price Range (should return validation error)
test_endpoint "Search Cars - Invalid Price Range (should fail)" "$BASE_URL/search?minPrice=50000000&maxPrice=10000000&page=0&size=3" "400"

# Test 7: Search Cars - Sorting Options
echo -e "${BLUE}Testing: Search Cars - Different Sort Options${NC}"
for sort in "price-asc" "price-desc" "year-asc" "year-desc" "mileage-asc" "mileage-desc"; do
    echo "Testing sort: $sort"
    curl -s "$BASE_URL/search?sort=$sort&page=0&size=2" | jq '.data.cars[0] | {sort: "'$sort'", make: .makeName, model: .modelName, price: .price, year: .year}' 2>/dev/null || echo "No jq available"
done
echo -e "\n"

# Test 8: Search Cars - Pagination
test_endpoint "Search Cars - Pagination (page=1, size=2)" "$BASE_URL/search?page=1&size=2"

# Test 9: Get Car Detail (if we have car IDs)
echo -e "${BLUE}Testing: Get Car Detail${NC}"
echo "First, getting a car ID from search results..."

# Get first car ID
car_id=$(curl -s "$BASE_URL/search?page=0&size=1" | jq -r '.data.cars[0].id' 2>/dev/null)

if [ "$car_id" != "null" ] && [ ! -z "$car_id" ]; then
    test_endpoint "Get Car Detail by ID" "$BASE_URL/$car_id"
else
    echo -e "${YELLOW}⚠️  No cars found, skipping car detail test${NC}"
fi
echo -e "\n"

echo -e "${GREEN}✅ API Testing completed!${NC}"
echo ""
echo -e "${BLUE}📝 Available endpoints:${NC}"
echo "- GET $BASE_URL/health"
echo "- GET $BASE_URL/search?[filters]"
echo "- GET $BASE_URL/{id}"
echo ""
echo -e "${BLUE}🔍 Search Parameters:${NC}"
echo "- value: Text search"
echo "- minPrice, maxPrice: Price range"
echo "- selectedMakes: Make names (comma-separated)"
echo "- selectedModels: Model names (comma-separated)"
echo "- selectedTrims: Trim names (comma-separated)"
echo "- selectedBodyTypes: Body type names (comma-separated)"
echo "- selectedTransmission: Transmission type"
echo "- sort: relevance|price-asc|price-desc|year-asc|year-desc|mileage-asc|mileage-desc"
echo "- page: Page number (0-based)"
echo "- size: Page size (1-100)"
