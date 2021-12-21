import Foundation

/// A struct representing a header content type value
public struct ContentType: Hashable, ExpressibleByStringLiteral {
    let value: String

    public init(value: String) {
      self.value = value
    }

    public init(stringLiteral value: StringLiteralType) {
      self.value = value
    }
}

extension ContentType {
    public static let json: Self = "application/json"
}
