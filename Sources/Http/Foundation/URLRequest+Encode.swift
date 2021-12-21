import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
    func encodedBody(_ body: Encodable, encoder: ContentDataEncoder) throws -> Self {
        var request = self
        
        try request.encodeBody(body, encoder: encoder)
        
        return request
    }
    
    mutating func encodeBody(_ body: Encodable, encoder: ContentDataEncoder) throws {
        httpBody = try body.encoded(with: encoder)
        setHeader(.contentType, value: type(of: encoder).contentType.value)
    }

    mutating func setHeader(_ header: Header, value: String?) {
      setValue(value, forHTTPHeaderField: header.key)
    }
}
