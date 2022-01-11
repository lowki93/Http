import Foundation

public enum Method: String {
  case get
  case post
  case put
  case delete
}

/// An Http request expecting an `Output` response
public struct Request<Output> {

  /// request relative path
  public let path: String
  public let method: Method
  public let body: Encodable?
  public let parameters: [String: String]
  public private(set) var headers: [HTTPHeader: String] = [:]

  public static func get<Endpoint: Path>(_ path: Endpoint, parameters: [String: String] = [:]) -> Self {
    self.init(path: path, method: .get, parameters: parameters, body: nil)
  }

  public static func post<Endpoint: Path>(_ path: Endpoint, body: Encodable?, parameters: [String: String] = [:])
  -> Self {
    self.init(path: path, method: .post, parameters: parameters, body: body)
  }

  public static func put<Endpoint: Path>(_ path: Endpoint, body: Encodable, parameters: [String: String] = [:])
  -> Self {
    self.init(path: path, method: .put, parameters: parameters, body: body)
  }

  public static func delete<Endpoint: Path>(_ path: Endpoint, parameters: [String: String] = [:]) -> Self {
    self.init(path: path, method: .delete, parameters: parameters, body: nil)
  }

  public mutating func headers(_ headers: [HTTPHeader: String]) -> Self {
    self.headers.merge(headers) { $1 }
    return self
  }

  private init<Endpoint: Path>(path: Endpoint, method: Method, parameters: [String: String] = [:], body: Encodable?) {
    self.path = path.rawValue
    self.method = method
    self.body = body
    self.parameters = parameters
  }

}
