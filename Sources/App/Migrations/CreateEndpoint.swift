import Fluent

struct CreateEndpoint: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("endpoints")
            .id()
            .field("project_id", .uuid, .required, .references("projects", "id"))
            .field("method", .string, .required)
            .field("path", .string, .required)
            .field("name", .string, .required)
            .field("description", .string)
            .field("is_enabled", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("endpoints").delete()
    }
}