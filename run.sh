#!/bin/bash

echo "🚀 Starting APIMock application..."

# Set environment variables
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=password
export DATABASE_NAME=apimock

echo "Environment configured:"
echo "  DATABASE_HOST: $DATABASE_HOST"
echo "  DATABASE_PORT: $DATABASE_PORT"
echo "  DATABASE_USERNAME: $DATABASE_USERNAME"
echo "  DATABASE_NAME: $DATABASE_NAME"

# Build and run the application
echo ""
echo "Building application..."
swift build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "Starting server on http://localhost:8080"
    echo "Press Ctrl+C to stop the server"
    echo ""
    swift run
else
    echo "❌ Build failed!"
    exit 1
fi