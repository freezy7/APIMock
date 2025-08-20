#!/bin/bash

echo "🧪 Testing APIMock API..."

BASE_URL="http://localhost:8080"

echo ""
echo "1. Creating a sample project..."
PROJECT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sample API",
    "description": "A sample REST API for testing",
    "baseUrl": "https://api.example.com"
  }')

echo "Project created: $PROJECT_RESPONSE"

# Extract project ID (this would need proper JSON parsing in a real script)
PROJECT_ID=$(echo $PROJECT_RESPONSE | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
echo "Project ID: $PROJECT_ID"

echo ""
echo "2. Creating a sample endpoint..."
ENDPOINT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects/$PROJECT_ID/endpoints" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "GET",
    "path": "/users",
    "name": "Get Users",
    "description": "Retrieve a list of users"
  }')

echo "Endpoint created: $ENDPOINT_RESPONSE"

# Extract endpoint ID
ENDPOINT_ID=$(echo $ENDPOINT_RESPONSE | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
echo "Endpoint ID: $ENDPOINT_ID"

echo ""
echo "3. Creating a sample response..."
RESPONSE_RESULT=$(curl -s -X POST "$BASE_URL/api/endpoints/$ENDPOINT_ID/responses" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Success Response",
    "statusCode": 200,
    "contentType": "application/json",
    "body": "{\"users\":[{\"id\":1,\"name\":\"John Doe\",\"email\":\"john@example.com\"},{\"id\":2,\"name\":\"Jane Smith\",\"email\":\"jane@example.com\"}]}",
    "delayMs": 100,
    "isDefault": true
  }')

echo "Response created: $RESPONSE_RESULT"

echo ""
echo "4. Testing the mock endpoint..."
MOCK_URL="$BASE_URL/mock/$PROJECT_ID/users"
echo "Mock URL: $MOCK_URL"

MOCK_RESPONSE=$(curl -s -w "\nHTTP Status: %{http_code}\nResponse Time: %{time_total}s\n" "$MOCK_URL")
echo "Mock response:"
echo "$MOCK_RESPONSE"

echo ""
echo "✅ Test completed! You can now:"
echo "   - Visit $BASE_URL/dashboard to see the web interface"
echo "   - Test the mock endpoint at $MOCK_URL"
echo "   - Use the API endpoints to manage your mocks"