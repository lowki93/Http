import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    /// Return URL for the request
    /// - Parameter for: base url for the request
    func url(for baseURL: URL) throws -> URL {
        let url = baseURL.appendingPathComponent(path)
        
        guard var components = URLComponents(string: url.absoluteString) else {
            throw URL.Error.invalid(base: baseURL, path: path)
        }
        
        let queryItems = (components.queryItems ?? [])
            + parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw URL.Error.invalid(components: components)
        }
        
        return url
    }
}

public extension URL {
    enum Error: Swift.Error {
        case invalid(base: URL, path: String)
        case invalid(components: URLComponents)
    }
}

public extension URLComponents {
    enum Error: Swift.Error {
        case invalid(base: URL, path: String)
    }
}
