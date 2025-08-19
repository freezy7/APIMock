import Fluent

struct CreateResponse: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("mock_responses")
            .id()
            .field("endpoint_id", .uuid, .required, .references("endpoints", "id"))
            .field("name", .string, .required)
            .field("status_code", .int, .required)
            .field("headers", .string)
            .field("body", .string)
            .field("content_type", .string, .required)
            .field("delay_ms", .int, .required)
            .field("is_default", .bool, .required)
            .field("probability", .double, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("mock_responses").delete()
    }
}