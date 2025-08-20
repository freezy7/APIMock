#!/bin/bash

# Set up environment for APIMock development
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_USERNAME=apimock
export DATABASE_PASSWORD=password
export DATABASE_NAME=apimock

echo "Environment variables set for APIMock development"
echo "DATABASE_HOST: $DATABASE_HOST"
echo "DATABASE_PORT: $DATABASE_PORT"
echo "DATABASE_USERNAME: $DATABASE_USERNAME"
echo "DATABASE_NAME: $DATABASE_NAME"

# Create a simple HTML response for testing while we fix the Leaf issues
cat > /tmp/simple_response.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APIMock - API Mock Server</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <div class="container mx-auto py-8">
        <h1 class="text-4xl font-bold text-center text-blue-600 mb-8">APIMock Server</h1>
        <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-2xl font-semibold mb-4">Welcome to APIMock</h2>
            <p class="text-gray-600 mb-4">Your API Mock server is running successfully!</p>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="bg-blue-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-blue-800">Create Projects</h3>
                    <p class="text-sm text-blue-600">Organize your API endpoints into projects</p>
                </div>
                <div class="bg-green-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-green-800">Mock Endpoints</h3>
                    <p class="text-sm text-green-600">Create realistic API responses</p>
                </div>
                <div class="bg-purple-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-purple-800">Test Responses</h3>
                    <p class="text-sm text-purple-600">Simulate different scenarios</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "Created simple HTML response for testing"