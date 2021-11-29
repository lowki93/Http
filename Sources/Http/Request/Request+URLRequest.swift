import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    func toURLRequest(base baseURL: URL, encoder: DataContentEncoder) throws -> URLRequest {
        var request = try URLRequest(url: url(for: baseURL))
        
        request.httpMethod = method.rawValue.uppercased()
        
        if let body = body {
            try request.encodeBody(body, encoder: encoder)
        }
        
        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        return request
    }
}
