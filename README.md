# APIMock

A powerful API Mock server built with Vapor Swift and PostgreSQL, featuring a beautiful TailwindCSS interface.

## Features

- **Project Management**: Organize your API endpoints into projects
- **Mock Endpoints**: Create realistic API endpoints with custom responses
- **Response Configuration**: Define status codes, headers, response bodies, and delays
- **Modern UI**: Beautiful, responsive web interface built with TailwindCSS
- **Database Storage**: Persistent storage using PostgreSQL
- **REST API**: Full REST API for programmatic management

## Quick Start

### Prerequisites

- Swift 5.9+
- PostgreSQL
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/freezy7/APIMock.git
cd APIMock
```

2. Set up PostgreSQL database:
```bash
# Create database
createdb apimock

# Or using PostgreSQL CLI
psql -c "CREATE DATABASE apimock;"
```

3. Configure environment variables:
```bash
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_USERNAME=your_username
export DATABASE_PASSWORD=your_password
export DATABASE_NAME=apimock
```

4. Build and run:
```bash
swift run
```

5. Open your browser and navigate to `http://localhost:8080`

## Database Models

### Project
- `id`: UUID (Primary Key)
- `name`: String (Required)
- `description`: String (Optional)
- `baseUrl`: String (Optional)
- `createdAt`, `updatedAt`: Timestamps

### Endpoint
- `id`: UUID (Primary Key)
- `projectId`: UUID (Foreign Key)
- `method`: String (GET, POST, PUT, DELETE, etc.)
- `path`: String (URL path)
- `name`: String (Display name)
- `description`: String (Optional)
- `isEnabled`: Boolean
- `createdAt`, `updatedAt`: Timestamps

### MockResponse
- `id`: UUID (Primary Key)
- `endpointId`: UUID (Foreign Key)
- `name`: String (Response name)
- `statusCode`: Integer (HTTP status code)
- `headers`: String (Custom headers)
- `body`: String (Response body)
- `contentType`: String (MIME type)
- `delayMs`: Integer (Response delay in milliseconds)
- `isDefault`: Boolean (Default response flag)
- `probability`: Double (Response probability 0.0-1.0)
- `createdAt`, `updatedAt`: Timestamps

### RequestRule
- `id`: UUID (Primary Key)
- `endpointId`: UUID (Foreign Key)
- `ruleType`: String (query, header, body, path_param)
- `key`: String (Parameter name)
- `value`: String (Expected value)
- `condition`: String (equals, contains, regex, exists)
- `isRequired`: Boolean
- `createdAt`, `updatedAt`: Timestamps

## API Endpoints

### Web Interface
- `GET /` - Redirect to dashboard
- `GET /dashboard` - Main dashboard
- `GET /projects` - Projects list
- `GET /projects/new` - Create project form
- `POST /projects` - Create new project
- `GET /projects/:id` - Project details
- `GET /projects/:id/endpoints/new` - Create endpoint form
- `POST /projects/:id/endpoints` - Create new endpoint
- `GET /endpoints/:id` - Endpoint details
- `GET /endpoints/:id/responses/new` - Create response form
- `POST /endpoints/:id/responses` - Create new response

### REST API
- `GET /api/projects` - List all projects
- `POST /api/projects` - Create project
- `GET /api/projects/:id` - Get project
- `PUT /api/projects/:id` - Update project
- `DELETE /api/projects/:id` - Delete project
- `GET /api/projects/:id/endpoints` - List endpoints
- `POST /api/projects/:id/endpoints` - Create endpoint
- `GET /api/endpoints/:id` - Get endpoint
- `PUT /api/endpoints/:id` - Update endpoint
- `DELETE /api/endpoints/:id` - Delete endpoint
- `GET /api/endpoints/:id/responses` - List responses
- `POST /api/endpoints/:id/responses` - Create response
- `PUT /api/responses/:id` - Update response
- `DELETE /api/responses/:id` - Delete response

### Mock API
- `ANY /mock/:projectId/**` - Serve mock responses

## Usage Example

1. **Create a Project**: Use the web interface to create a new API project
2. **Add Endpoints**: Define your API endpoints with HTTP methods and paths
3. **Configure Responses**: Set up mock responses with status codes, headers, and body content
4. **Test Your Mocks**: Access your mocked endpoints at `/mock/{projectId}{endpointPath}`

Example mock URL: `http://localhost:8080/mock/12345678-1234-1234-1234-123456789012/api/users/1`

## Development

### Running Tests
```bash
swift test
```

### Database Migrations
Migrations run automatically on startup. To run manually:
```bash
swift run App migrate
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Tech Stack

- **Backend**: Vapor Swift 4.x
- **Database**: PostgreSQL with Fluent ORM
- **Frontend**: HTML, TailwindCSS, JavaScript
- **Templating**: Leaf (currently using inline HTML for simplicity)
- **Icons**: Font Awesome
