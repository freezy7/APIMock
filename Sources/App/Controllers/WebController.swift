import Fluent
import Vapor

struct WebController {
    func dashboard(req: Request) async throws -> View {
        let projects = try await Project.query(on: req.db)
            .with(\.$endpoints)
            .all()
        
        let view: View = try await req.view.render("dashboard", [
            "projects": projects,
            "title": "APIMock Dashboard"
        ])
        return view
    }
    
    func projectsList(req: Request) async throws -> View {
        let projects = try await Project.query(on: req.db)
            .with(\.$endpoints)
            .all()
        
        let view: View = try await req.view.render("projects/list", [
            "projects": projects,
            "title": "Projects"
        ])
        return view
    }
    
    func createProjectForm(req: Request) async throws -> View {
        let view: View = try await req.view.render("projects/create", [
            "title": "Create Project"
        ])
        return view
    }
    
    func createProject(req: Request) async throws -> Response {
        let project = try req.content.decode(Project.self)
        try await project.save(on: req.db)
        return req.redirect(to: "/projects/\(project.id!)")
    }
    
    func projectDetail(req: Request) async throws -> View {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.query(on: req.db)
            .filter(\.$id == projectID)
            .with(\.$endpoints)
            .first() else {
            throw Abort(.notFound)
        }
        
        let view: View = try await req.view.render("projects/detail", [
            "project": project,
            "title": project.name
        ])
        return view
    }
    
    func createEndpointForm(req: Request) async throws -> View {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let project = try await Project.find(projectID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let view: View = try await req.view.render("endpoints/create", [
            "project": project,
            "title": "Create Endpoint"
        ])
        return view
    }
    
    func createEndpoint(req: Request) async throws -> Response {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        struct CreateEndpointData: Content {
            let method: String
            let path: String
            let name: String
            let description: String?
        }
        
        let data = try req.content.decode(CreateEndpointData.self)
        let endpoint = Endpoint(
            projectID: projectID,
            method: data.method,
            path: data.path,
            name: data.name,
            description: data.description
        )
        
        try await endpoint.save(on: req.db)
        return req.redirect(to: "/endpoints/\(endpoint.id!)")
    }
    
    func endpointDetail(req: Request) async throws -> View {
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
        
        let view: View = try await req.view.render("endpoints/detail", [
            "endpoint": endpoint,
            "title": endpoint.name
        ])
        return view
    }
    
    func createResponseForm(req: Request) async throws -> View {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let endpoint = try await Endpoint.query(on: req.db)
            .filter(\.$id == endpointID)
            .with(\.$project)
            .first() else {
            throw Abort(.notFound)
        }
        
        let view: View = try await req.view.render("responses/create", [
            "endpoint": endpoint,
            "title": "Create Response"
        ])
        return view
    }
    
    func createResponse(req: Request) async throws -> Response {
        guard let endpointID = req.parameters.get("endpointID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        struct CreateResponseData: Content {
            let name: String
            let statusCode: Int
            let headers: String?
            let body: String?
            let contentType: String
            let delayMs: Int
            let isDefault: Bool
        }
        
        let data = try req.content.decode(CreateResponseData.self)
        let response = MockResponse(
            endpointID: endpointID,
            name: data.name,
            statusCode: data.statusCode,
            headers: data.headers,
            body: data.body,
            contentType: data.contentType,
            delayMs: data.delayMs,
            isDefault: data.isDefault
        )
        
        try await response.save(on: req.db)
        return req.redirect(to: "/endpoints/\(endpointID)")
    }
}