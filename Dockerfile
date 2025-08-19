FROM swift:5.9-jammy

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY Package.swift Package.resolved ./

# Resolve dependencies
RUN swift package resolve

# Copy source code
COPY . .

# Build the application
RUN swift build --configuration release

# Expose port
EXPOSE 8080

# Run the application
CMD ["swift", "run", "--configuration", "release"]