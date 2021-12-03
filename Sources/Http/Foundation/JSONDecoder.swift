import Foundation

extension JSONDecoder: DataContentDecoder {
  public var contentType: String { "application/json" }
}
