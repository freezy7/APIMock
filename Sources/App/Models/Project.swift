import Fluent
import Vapor

final class Project: Model, Content {
    static let schema = "projects"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "base_url")
    var baseUrl: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$project)
    var endpoints: [Endpoint]
    
    init() { }
    
    init(id: UUID? = nil, name: String, description: String? = nil, baseUrl: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.baseUrl = baseUrl
    }
}