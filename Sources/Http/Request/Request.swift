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
  public var parameters: [String: String]
  public var headers: [String: String] = [:]

  public static func get<Endpoint: Path>(_ path: Endpoint, parameters: [String: String] = [:]) -> Self {
    self.init(path: path, method: .get, parameters: parameters, body: nil)
  }

  public static func post<Endpoint: Path>(_ path: Endpoint, body: Encodable?) -> Self {
    self.init(path: path, method: .post, body: body)
  }

  private init<Endpoint: Path>(path: Endpoint, method: Method, parameters: [String: String] = [:], body: Encodable?) {
    self.path = path.rawValue
    self.method = method
    self.body = body
    self.parameters = parameters
  }

}
