import Fluent

struct CreateProject: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("base_url", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("projects").delete()
    }
}