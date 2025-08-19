import Fluent
import Vapor

final class Endpoint: Model, Content {
    static let schema = "endpoints"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "project_id")
    var project: Project
    
    @Field(key: "method")
    var method: String
    
    @Field(key: "path")
    var path: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "is_enabled")
    var isEnabled: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$endpoint)
    var responses: [MockResponse]
    
    @Children(for: \.$endpoint)
    var requestRules: [RequestRule]
    
    init() { }
    
    init(id: UUID? = nil, projectID: Project.IDValue, method: String, path: String, name: String, description: String? = nil, isEnabled: Bool = true) {
        self.id = id
        self.$project.id = projectID
        self.method = method
        self.path = path
        self.name = name
        self.description = description
        self.isEnabled = isEnabled
    }
}