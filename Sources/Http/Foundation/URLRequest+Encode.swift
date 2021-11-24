import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
    func encodedBody(_ body: Encodable, encoder: DataContentEncoder) throws -> Self {
        var request = self
        
        try request.encodeBody(body, encoder: encoder)
        
        return request
    }
    
    mutating func encodeBody(_ body: Encodable, encoder: DataContentEncoder) throws {
        httpBody = try body.encoded(with: encoder)
        setValue(encoder.contentType, forHTTPHeaderField: "Content-Type")
    }
}
