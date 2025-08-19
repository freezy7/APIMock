import Fluent
import Vapor

struct APIController {
    func getAllProjects(req: Request) async throws -> [Project] {
        return try await Project.query(on: req.db)
            .with(\.$endpoints)
            .all()
    }
    
    func createProject(req: Request) async throws -> Project {
        let project = try req.content.decode(Project.self)
        try await project.save(on: req.db)
        return project
    }
    
    func getProject(req: Request) async throws -> Project {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.query(on: req.db)
            .filter(\.$id == projectID)
            .with(\.$endpoints)
            .first() else {
            throw Abort(.notFound)
        }
        
        return project
    }
    
    func updateProject(req: Request) async throws -> Project {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.find(projectID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let updateData = try req.content.decode(Project.self)
        project.name = updateData.name
        project.description = updateData.description
        project.baseUrl = updateData.baseUrl
        
        try await project.save(on: req.db)
        return project
    }
    
    func deleteProject(req: Request) async throws -> HTTPStatus {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.find(projectID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await project.delete(on: req.db)
        return .noContent
    }
    
    func getEndpoints(req: Request) async throws -> [Endpoint] {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await Endpoint.query(on: req.db)
            .filter(\.$project.$id == projectID)
            .with(\.$responses)
            .all()
    }
    
    func createEndpoint(req: Request) async throws -> Endpoint {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        struct CreateEndpointData: Content {
            let method: String
            let path: String
            let name: String
            let description: String?
            let isEnabled: Bool?
        }
        
        let data = try req.content.decode(CreateEndpointData.self)
        let endpoint = Endpoint(
            projectID: projectID,
            method: data.method,
            path: data.path,
            name: data.name,
            description: data.description,
            isEnabled: data.isEnabled ?? true
        )
        
        try await endpoint.save(on: req.db)
        return endpoint
    }
    
    func getEndpoint(req: Request) async throws -> Endpoint {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let endpoint = try await Endpoint.query(on: req.db)
            .filter(\.$id == endpointID)
            .with(\.$project)
            .with(\.$responses)
            .with(\.$requestRules)
            .first() else {
            throw Abort(.notFound)
        }
        
        return endpoint
    }
    
    func updateEndpoint(req: Request) async throws -> Endpoint {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let endpoint = try await Endpoint.find(endpointID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        struct UpdateEndpointData: Content {
            let method: String?
            let path: String?
            let name: String?
            let description: String?
            let isEnabled: Bool?
        }
        
        let data = try req.content.decode(UpdateEndpointData.self)
        
        if let method = data.method { endpoint.method = method }
        if let path = data.path { endpoint.path = path }
        if let name = data.name { endpoint.name = name }
        if let description = data.description { endpoint.description = description }
        if let isEnabled = data.isEnabled { endpoint.isEnabled = isEnabled }
        
        try await endpoint.save(on: req.db)
        return endpoint
    }
    
    func deleteEndpoint(req: Request) async throws -> HTTPStatus {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let endpoint = try await Endpoint.find(endpointID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await endpoint.delete(on: req.db)
        return .noContent
    }
    
    func getResponses(req: Request) async throws -> [MockResponse] {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await MockResponse.query(on: req.db)
            .filter(\.$endpoint.$id == endpointID)
            .all()
    }
    
    func createResponse(req: Request) async throws -> MockResponse {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        struct CreateResponseData: Content {
            let name: String
            let statusCode: Int
            let headers: String?
            let body: String?
            let contentType: String?
            let delayMs: Int?
            let isDefault: Bool?
            let probability: Double?
        }
        
        let data = try req.content.decode(CreateResponseData.self)
        let response = MockResponse(
            endpointID: endpointID,
            name: data.name,
            statusCode: data.statusCode,
            headers: data.headers,
            body: data.body,
            contentType: data.contentType ?? "application/json",
            delayMs: data.delayMs ?? 0,
            isDefault: data.isDefault ?? false,
            probability: data.probability ?? 1.0
        )
        
        try await response.save(on: req.db)
        return response
    }
    
    func updateResponse(req: Request) async throws -> MockResponse {
        guard let responseID = req.parameters.get("responseID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let response = try await MockResponse.find(responseID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        struct UpdateResponseData: Content {
            let name: String?
            let statusCode: Int?
            let headers: String?
            let body: String?
            let contentType: String?
            let delayMs: Int?
            let isDefault: Bool?
            let probability: Double?
        }
        
        let data = try req.content.decode(UpdateResponseData.self)
        
        if let name = data.name { response.name = name }
        if let statusCode = data.statusCode { response.statusCode = statusCode }
        if let headers = data.headers { response.headers = headers }
        if let body = data.body { response.body = body }
        if let contentType = data.contentType { response.contentType = contentType }
        if let delayMs = data.delayMs { response.delayMs = delayMs }
        if let isDefault = data.isDefault { response.isDefault = isDefault }
        if let probability = data.probability { response.probability = probability }
        
        try await response.save(on: req.db)
        return response
    }
    
    func deleteResponse(req: Request) async throws -> HTTPStatus {
        guard let responseID = req.parameters.get("responseID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let response = try await MockResponse.find(responseID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await response.delete(on: req.db)
        return .noContent
    }
}