import Fluent
import Vapor

final class RequestRule: Model, Content {
    static let schema = "request_rules"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "endpoint_id")
    var endpoint: Endpoint
    
    @Field(key: "rule_type")
    var ruleType: String // "query", "header", "body", "path_param"
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "condition")
    var condition: String // "equals", "contains", "regex", "exists"
    
    @Field(key: "is_required")
    var isRequired: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, endpointID: Endpoint.IDValue, ruleType: String, key: String, value: String, condition: String = "equals", isRequired: Bool = false) {
        self.id = id
        self.$endpoint.id = endpointID
        self.ruleType = ruleType
        self.key = key
        self.value = value
        self.condition = condition
        self.isRequired = isRequired
    }
}