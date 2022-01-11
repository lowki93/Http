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
}
