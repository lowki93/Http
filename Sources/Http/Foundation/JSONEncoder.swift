import Foundation

extension JSONEncoder: DataContentEncoder {
    public var contentType: String { "application/json" }
}
