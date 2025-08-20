import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Dashboard route (root)
    app.get { req async throws -> View in
        let projects = try await Project.query(on: req.db)
            .with(\.$endpoints) { endpoint in
                endpoint.with(\.$responses)
            }
            .all()
        
        struct DashboardContext: Content {
            let projects: [Project]
            let title: String
        }
        
        return try await req.view.render("dashboard", DashboardContext(projects: projects, title: "Dashboard"))
    }

    // Projects web routes
    app.get("projects") { req async throws -> View in
        let projects = try await Project.query(on: req.db)
            .with(\.$endpoints)
            .all()
            
        struct ProjectsContext: Content {
            let projects: [Project]
            let title: String
        }
        
        return try await req.view.render("projects/list", ProjectsContext(projects: projects, title: "Projects"))
    }
    
    app.get("projects", "new") { req async throws -> View in
        struct CreateProjectContext: Content {
            let title: String
        }
        return try await req.view.render("projects/create", CreateProjectContext(title: "Create Project"))
    }
    
    app.post("projects") { req async throws -> Response in
        let data = try req.content.decode(Project.self)
        try await data.save(on: req.db)
        return req.redirect(to: "/projects")
    }
    
    app.get("projects", ":projectID") { req async throws -> View in
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.find(projectID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await project.$endpoints.load(on: req.db)
        for endpoint in project.endpoints {
            try await endpoint.$responses.load(on: req.db)
        }
        
        struct ProjectDetailContext: Content {
            let project: Project
            let title: String
        }
        
        return try await req.view.render("projects/detail", ProjectDetailContext(project: project, title: project.name))
    }
    
    // Endpoint web routes
    app.get("projects", ":projectID", "endpoints", "new") { req async throws -> View in
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.find(projectID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        struct CreateEndpointContext: Content {
            let project: Project
            let title: String
        }
        
        return try await req.view.render("endpoints/create", CreateEndpointContext(project: project, title: "Create Endpoint"))
    }
    
    app.post("projects", ":projectID", "endpoints") { req async throws -> Response in
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        struct EndpointData: Content {
            let name: String
            let method: String
            let path: String
            let description: String?
            let isEnabled: Bool?
        }
        
        let data = try req.content.decode(EndpointData.self)
        let endpoint = Endpoint(
            projectID: projectID,
            method: data.method,
            path: data.path,
            name: data.name,
            description: data.description,
            isEnabled: data.isEnabled ?? true
        )
        
        try await endpoint.save(on: req.db)
        return req.redirect(to: "/projects/\(projectID)")
    }
    
    app.get("endpoints", ":endpointID") { req async throws -> View in
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let endpoint = try await Endpoint.find(endpointID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await endpoint.$project.load(on: req.db)
        try await endpoint.$responses.load(on: req.db)
        
        struct EndpointDetailContext: Content {
            let endpoint: Endpoint
            let title: String
        }
        
        return try await req.view.render("endpoints/detail", EndpointDetailContext(endpoint: endpoint, title: endpoint.name))
    }
    
    // Response web routes
    app.get("endpoints", ":endpointID", "responses", "new") { req async throws -> View in
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let endpoint = try await Endpoint.find(endpointID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await endpoint.$project.load(on: req.db)
        
        struct CreateResponseContext: Content {
            let endpoint: Endpoint
            let title: String
        }
        
        return try await req.view.render("responses/create", CreateResponseContext(endpoint: endpoint, title: "Create Response"))
    }
    
    app.post("endpoints", ":endpointID", "responses") { req async throws -> Response in
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        struct ResponseData: Content {
            let name: String
            let statusCode: Int
            let contentType: String
            let headers: String?
            let body: String?
            let delayMs: Int?
            let isDefault: Bool?
        }
        
        let data = try req.content.decode(ResponseData.self)
        let response = MockResponse(
            endpointID: endpointID,
            name: data.name,
            statusCode: data.statusCode,
            headers: data.headers,
            body: data.body,
            contentType: data.contentType,
            delayMs: data.delayMs ?? 0,
            isDefault: data.isDefault ?? false
        )
        
        try await response.save(on: req.db)
        return req.redirect(to: "/endpoints/\(endpointID)")
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