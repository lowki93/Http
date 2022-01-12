import Foundation

/// A struct representing a request header key
public struct HTTPHeader: Hashable, ExpressibleByStringLiteral {
  public let key: String

  public init(stringLiteral value: StringLiteralType) {
    self.key = value
  }
}

extension HTTPHeader {
  public static let accept: Self = "Accept"
  public static let authentication: Self = "Authentication"
  public static let contentType: Self = "Content-Type"
  public static var contentDisposition: Self = "Content-Disposition"
  public static func contentDisposition(disposition: String) -> String {
    [Self.contentDisposition.key, disposition].joined(separator: ": ")
  }
  public static func contentType(_ disposition: String) -> String {
    [Self.contentType.key, disposition].joined(separator: ": ")
  }
}
