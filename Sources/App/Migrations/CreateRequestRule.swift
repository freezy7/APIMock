import Fluent

struct CreateRequestRule: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("request_rules")
            .id()
            .field("endpoint_id", .uuid, .required, .references("endpoints", "id"))
            .field("rule_type", .string, .required)
            .field("key", .string, .required)
            .field("value", .string, .required)
            .field("condition", .string, .required)
            .field("is_required", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("request_rules").delete()
    }
}