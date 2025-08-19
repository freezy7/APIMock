import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        return "APIMock API Server is running. Use /api/* for API endpoints and /mock/{projectId}/* for mock responses."
    }

    // API routes
    let apiController = APIController()
    app.group("api") { api in
        api.get("projects", use: apiController.getAllProjects)
        api.post("projects", use: apiController.createProject)
        api.get("projects", ":projectID", use: apiController.getProject)
        api.put("projects", ":projectID", use: apiController.updateProject)
        api.delete("projects", ":projectID", use: apiController.deleteProject)
        
        api.get("projects", ":projectID", "endpoints", use: apiController.getEndpoints)
        api.post("projects", ":projectID", "endpoints", use: apiController.createEndpoint)
        api.get("endpoints", ":endpointID", use: apiController.getEndpoint)
        api.put("endpoints", ":endpointID", use: apiController.updateEndpoint)
        api.delete("endpoints", ":endpointID", use: apiController.deleteEndpoint)
        
        api.get("endpoints", ":endpointID", "responses", use: apiController.getResponses)
        api.post("endpoints", ":endpointID", "responses", use: apiController.createResponse)
        api.put("responses", ":responseID", use: apiController.updateResponse)
        api.delete("responses", ":responseID", use: apiController.deleteResponse)
    }

    // Mock API routes - these handle the actual mocked endpoints
    let mockController = MockController()
    app.group("mock", ":projectID") { mock in
        mock.on(.GET, "**", use: mockController.handleRequest)
        mock.on(.POST, "**", use: mockController.handleRequest)
        mock.on(.PUT, "**", use: mockController.handleRequest)
        mock.on(.DELETE, "**", use: mockController.handleRequest)
        mock.on(.PATCH, "**", use: mockController.handleRequest)
    }
}