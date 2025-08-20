import Fluent
import Vapor

final class MockResponse: Model, Content {
    static let schema = "mock_responses"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "endpoint_id")
    var endpoint: Endpoint
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "status_code")
    var statusCode: Int
    
    @Field(key: "headers")
    var headers: String?
    
    @Field(key: "body")
    var body: String?
    
    @Field(key: "content_type")
    var contentType: String
    
    @Field(key: "delay_ms")
    var delayMs: Int
    
    @Field(key: "is_default")
    var isDefault: Bool
    
    @Field(key: "probability")
    var probability: Double
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, endpointID: Endpoint.IDValue, name: String, statusCode: Int, headers: String? = nil, body: String? = nil, contentType: String = "application/json", delayMs: Int = 0, isDefault: Bool = false, probability: Double = 1.0) {
        self.id = id
        self.$endpoint.id = endpointID
        self.name = name
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.contentType = contentType
        self.delayMs = delayMs
        self.isDefault = isDefault
        self.probability = probability
    }
}