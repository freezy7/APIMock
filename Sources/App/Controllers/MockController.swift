import Fluent
import Vapor

struct MockController: Sendable {
    func handleRequest(req: Request) async throws -> Response {
        guard let projectID = req.parameters.get("projectID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Get the path after /mock/{projectID}/
        let pathComponents = req.url.path.split(separator: "/").dropFirst(2) // Remove "mock" and projectID
        let requestPath = "/" + pathComponents.joined(separator: "/")
        let method = req.method.rawValue
        
        // Find matching endpoint
        guard let endpoint = try await Endpoint.query(on: req.db)
            .filter(\.$project.$id == projectID)
            .filter(\.$method == method)
            .filter(\.$path == requestPath)
            .filter(\.$isEnabled == true)
            .with(\.$responses)
            .first() else {
            throw Abort(.notFound, reason: "No matching endpoint found for \(method) \(requestPath)")
        }
        
        // Get appropriate response
        let response = try await selectResponse(for: endpoint, req: req)
        
        // Apply delay if configured
        if response.delayMs > 0 {
            try await Task.sleep(nanoseconds: UInt64(response.delayMs) * 1_000_000)
        }
        
        // Build response
        var responseBuilder = Response(status: HTTPStatus(statusCode: response.statusCode))
        
        // Set content type
        let parts = response.contentType.split(separator: "/")
        if parts.count == 2 {
            responseBuilder.headers.contentType = HTTPMediaType(type: String(parts[0]), subType: String(parts[1]))
        }
        
        // Parse and set custom headers
        if let headersString = response.headers {
            let headers = parseHeaders(headersString)
            for (key, value) in headers {
                responseBuilder.headers.replaceOrAdd(name: key, value: value)
            }
        }
        
        // Set body
        if let body = response.body {
            responseBuilder.body = Response.Body(string: body)
        }
        
        return responseBuilder
    }
    
    private func selectResponse(for endpoint: Endpoint, req: Request) async throws -> MockResponse {
        let responses = endpoint.responses
        
        // If no responses, return 404
        guard !responses.isEmpty else {
            throw Abort(.notFound, reason: "No responses configured for this endpoint")
        }
        
        // If only one response, return it
        if responses.count == 1 {
            return responses[0]
        }
        
        // Check for default response first
        if let defaultResponse = responses.first(where: { $0.isDefault }) {
            return defaultResponse
        }
        
        // TODO: Implement probability-based selection
        // For now, just return the first response
        return responses[0]
    }
    
    private func parseHeaders(_ headersString: String) -> [String: String] {
        var headers: [String: String] = [:]
        
        let lines = headersString.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                headers[key] = value
            }
        }
        
        return headers
    }
}