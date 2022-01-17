import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    func toURLRequest(base baseURL: URL, encoder: ContentDataEncoder) throws -> URLRequest {
        var request = try URLRequest(url: url(for: baseURL))
        
        request.httpMethod = method.rawValue.uppercased()
        
        if let body = body {
          switch body {
          case .encodable(let body):
            try request.encodeBody(body, encoder: encoder)
          case .multipart(let multipart):
            try request.multipartBody(multipart)
          }
        }
        
        for (header, value) in headers {
            request.setHeader(header, value: value)
        }
        
        return request
    }
}
