import Fluent
import Vapor

import Fluent
import Vapor

struct WebController {
    func dashboard(req: Request) async throws -> Response {
        let projects = try await Project.query(on: req.db)
            .with(\.$endpoints)
            .all()
        
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>APIMock Dashboard</title>
            <script src="https://cdn.tailwindcss.com"></script>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        </head>
        <body class="bg-gray-100 min-h-screen">
            <nav class="bg-blue-600 text-white shadow-lg">
                <div class="max-w-7xl mx-auto px-4">
                    <div class="flex justify-between items-center h-16">
                        <div class="flex items-center">
                            <a href="/" class="text-xl font-bold">
                                <i class="fas fa-cloud mr-2"></i>APIMock
                            </a>
                        </div>
                        <div class="flex space-x-4">
                            <a href="/dashboard" class="bg-blue-700 px-3 py-2 rounded-md text-sm font-medium">
                                <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
                            </a>
                            <a href="/projects" class="hover:bg-blue-700 px-3 py-2 rounded-md text-sm font-medium">
                                <i class="fas fa-folder mr-2"></i>Projects
                            </a>
                        </div>
                    </div>
                </div>
            </nav>

            <main class="max-w-7xl mx-auto py-6 px-4">
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">Welcome to APIMock</h1>
                    <p class="text-gray-600">Manage your API mocks with ease</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-white overflow-hidden shadow rounded-lg">
                        <div class="p-5">
                            <div class="flex items-center">
                                <div class="flex-shrink-0">
                                    <i class="fas fa-folder text-blue-500 text-2xl"></i>
                                </div>
                                <div class="ml-5 w-0 flex-1">
                                    <dl>
                                        <dt class="text-sm font-medium text-gray-500 truncate">Total Projects</dt>
                                        <dd class="text-lg font-medium text-gray-900">\(projects.count)</dd>
                                    </dl>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white overflow-hidden shadow rounded-lg">
                        <div class="p-5">
                            <div class="flex items-center">
                                <div class="flex-shrink-0">
                                    <i class="fas fa-link text-green-500 text-2xl"></i>
                                </div>
                                <div class="ml-5 w-0 flex-1">
                                    <dl>
                                        <dt class="text-sm font-medium text-gray-500 truncate">Total Endpoints</dt>
                                        <dd class="text-lg font-medium text-gray-900">\(projects.reduce(0) { $0 + $1.endpoints.count })</dd>
                                    </dl>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white overflow-hidden shadow rounded-lg">
                        <div class="p-5">
                            <div class="flex items-center">
                                <div class="flex-shrink-0">
                                    <i class="fas fa-server text-purple-500 text-2xl"></i>
                                </div>
                                <div class="ml-5 w-0 flex-1">
                                    <dl>
                                        <dt class="text-sm font-medium text-gray-500 truncate">Active Mocks</dt>
                                        <dd class="text-lg font-medium text-gray-900">\(projects.flatMap { $0.endpoints }.filter { $0.isEnabled }.count)</dd>
                                    </dl>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white shadow overflow-hidden sm:rounded-md">
                    <div class="px-4 py-5 sm:p-6">
                        <div class="flex justify-between items-center mb-4">
                            <h2 class="text-lg leading-6 font-medium text-gray-900">Recent Projects</h2>
                            <a href="/projects/new" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium">
                                <i class="fas fa-plus mr-2"></i>New Project
                            </a>
                        </div>
                        
                        \(projects.isEmpty ? """
                        <div class="text-center py-8">
                            <i class="fas fa-folder-open text-gray-400 text-4xl mb-4"></i>
                            <p class="text-gray-500 mb-4">No projects yet</p>
                            <a href="/projects/new" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium">
                                Create your first project
                            </a>
                        </div>
                        """ : """
                        <ul class="divide-y divide-gray-200">
                            \(projects.map { project in
                                """
                                <li class="py-4">
                                    <div class="flex items-center space-x-4">
                                        <div class="flex-shrink-0">
                                            <div class="h-10 w-10 bg-blue-100 rounded-full flex items-center justify-center">
                                                <i class="fas fa-folder text-blue-600"></i>
                                            </div>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <p class="text-sm font-medium text-gray-900 truncate">
                                                <a href="/projects/\(project.id?.uuidString ?? "")" class="hover:text-blue-600">\(project.name)</a>
                                            </p>
                                            <p class="text-sm text-gray-500 truncate">
                                                \(project.description ?? "No description")
                                            </p>
                                        </div>
                                        <div class="flex-shrink-0 text-right">
                                            <p class="text-sm text-gray-500">\(project.endpoints.count) endpoints</p>
                                        </div>
                                    </div>
                                </li>
                                """
                            }.joined())
                        </ul>
                        """)
                    </div>
                </div>
            </main>

            <footer class="bg-gray-800 text-white mt-12">
                <div class="max-w-7xl mx-auto py-4 px-4 text-center">
                    <p>&copy; 2025 APIMock. Built with Vapor Swift and TailwindCSS.</p>
                </div>
            </footer>
        </body>
        </html>
        """
        
        return Response(status: .ok, headers: HTTPHeaders([("Content-Type", "text/html")]), body: .init(string: html))
    }
    
    func projectsList(req: Request) async throws -> Response {
        return req.redirect(to: "/dashboard")
    }
    
    func createProjectForm(req: Request) async throws -> Response {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Create Project - APIMock</title>
            <script src="https://cdn.tailwindcss.com"></script>
        </head>
        <body class="bg-gray-100 min-h-screen">
            <nav class="bg-blue-600 text-white shadow-lg">
                <div class="max-w-7xl mx-auto px-4">
                    <div class="flex justify-between items-center h-16">
                        <div class="flex items-center">
                            <a href="/" class="text-xl font-bold">APIMock</a>
                        </div>
                        <div class="flex space-x-4">
                            <a href="/dashboard" class="hover:bg-blue-700 px-3 py-2 rounded-md text-sm font-medium">Dashboard</a>
                        </div>
                    </div>
                </div>
            </nav>
            <main class="max-w-2xl mx-auto py-6 px-4">
                <div class="mb-8">
                    <a href="/dashboard" class="text-blue-600 hover:text-blue-800 mr-4">← Back to Dashboard</a>
                    <h1 class="text-3xl font-bold text-gray-900">Create New Project</h1>
                </div>
                <div class="bg-white shadow rounded-lg p-6">
                    <form action="/projects" method="POST">
                        <div class="mb-4">
                            <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Project Name *</label>
                            <input type="text" name="name" id="name" required class="w-full px-3 py-2 border border-gray-300 rounded-md">
                        </div>
                        <div class="mb-4">
                            <label for="description" class="block text-sm font-medium text-gray-700 mb-2">Description</label>
                            <textarea name="description" id="description" rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-md"></textarea>
                        </div>
                        <div class="mb-4">
                            <label for="baseUrl" class="block text-sm font-medium text-gray-700 mb-2">Base URL (Optional)</label>
                            <input type="url" name="baseUrl" id="baseUrl" class="w-full px-3 py-2 border border-gray-300 rounded-md">
                        </div>
                        <div class="flex justify-end space-x-4">
                            <a href="/dashboard" class="bg-gray-300 hover:bg-gray-400 text-gray-700 px-4 py-2 rounded-md text-sm font-medium">Cancel</a>
                            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium">Create Project</button>
                        </div>
                    </form>
                </div>
            </main>
        </body>
        </html>
        """
        return Response(status: .ok, headers: HTTPHeaders([("Content-Type", "text/html")]), body: .init(string: html))
    }
    
    func createProject(req: Request) async throws -> Response {
        let project = try req.content.decode(Project.self)
        try await project.save(on: req.db)
        return req.redirect(to: "/projects/\(project.id!)")
    }
    
    func projectDetail(req: Request) async throws -> Response {
        return Response(status: .ok, headers: HTTPHeaders([("Content-Type", "text/html")]), body: .init(string: "<h1>Project Detail - Coming Soon</h1>"))
    }
    
    func createEndpointForm(req: Request) async throws -> Response {
        return Response(status: .ok, headers: HTTPHeaders([("Content-Type", "text/html")]), body: .init(string: "<h1>Create Endpoint - Coming Soon</h1>"))
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
    
    func endpointDetail(req: Request) async throws -> Response {
        return Response(status: .ok, headers: HTTPHeaders([("Content-Type", "text/html")]), body: .init(string: "<h1>Endpoint Detail - Coming Soon</h1>"))
    }
    
    func createResponseForm(req: Request) async throws -> Response {
        return Response(status: .ok, headers: HTTPHeaders([("Content-Type", "text/html")]), body: .init(string: "<h1>Create Response - Coming Soon</h1>"))
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