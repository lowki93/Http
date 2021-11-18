import Foundation

public extension URLRequest {
    func encodedBody<Encoder: TopLevelEncoder>(_ body: Encodable, encoder: Encoder) -> Self {
        var request = self
        
        request.encodeBody(body, encoder: encoder)
        
        return request
    }
    
    mutating func encodeBody<Encoder: TopLevelEncoder>(_ body: Encodable, encoder: Encoder) {
        httpBody = try encoder.encode(body)
        setValue(encoder.contentType, forHTTPHeaderField: "Content-Type")
    }
}
