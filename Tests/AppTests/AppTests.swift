@testable import App
import XCTVapor
import FluentSQLiteDriver
import Fluent
import Leaf

final class AppTests: XCTestCase {
    func testDashboardRoute() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        // Configure database for testing
        app.databases.use(.sqlite(.memory), as: .sqlite)
        
        // Configure Leaf
        app.views.use(.leaf)
        
        // Add migrations
        app.migrations.add(CreateProject())
        app.migrations.add(CreateEndpoint())
        app.migrations.add(CreateResponse())
        app.migrations.add(CreateRequestRule())
        
        // Register routes
        try routes(app)
        
        // Run migrations
        try app.autoMigrate().wait()
        
        try app.test(.GET, "/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains("APIMock"))
        })
    }
    
    func testProjectsRoute() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        // Configure database for testing
        app.databases.use(.sqlite(.memory), as: .sqlite)
        
        // Configure Leaf
        app.views.use(.leaf)
        
        // Add migrations
        app.migrations.add(CreateProject())
        app.migrations.add(CreateEndpoint())
        app.migrations.add(CreateResponse())
        app.migrations.add(CreateRequestRule())
        
        // Register routes
        try routes(app)
        
        // Run migrations
        try app.autoMigrate().wait()
        
        try app.test(.GET, "/projects", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains("Projects"))
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