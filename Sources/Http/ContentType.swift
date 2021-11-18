import Foundation

/// A type representing a http content type
public protocol ContentType {
  /// the http content  type
  var contentType: String { get }
}
