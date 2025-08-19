@testable import App
import XCTVapor
import FluentSQLiteDriver
import Fluent

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        // Configure database for testing
        app.databases.use(.sqlite(.memory), as: .sqlite)
        
        // Add migrations
        app.migrations.add(CreateProject())
        app.migrations.add(CreateEndpoint())
        app.migrations.add(CreateResponse())
        app.migrations.add(CreateRequestRule())
        
        // Register routes
        try routes(app)
        
        try app.test(.GET, "/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains("APIMock API Server is running"))
        })
    }
    
    func testAPIEndpoints() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        // Configure database for testing
        app.databases.use(.sqlite(.memory), as: .sqlite)
        
        // Add migrations
        app.migrations.add(CreateProject())
        app.migrations.add(CreateEndpoint())
        app.migrations.add(CreateResponse())
        app.migrations.add(CreateRequestRule())
        
        // Register routes
        try routes(app)
        
        // Run migrations
        try app.autoMigrate().wait()
        
        try app.test(.GET, "/api/projects", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}