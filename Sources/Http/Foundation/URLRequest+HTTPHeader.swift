import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
  /// set a header on the request using `HTTPHeader`
  mutating func setHeader(_ header: HTTPHeader, value: String?) {
    setValue(value, forHTTPHeaderField: header.key)
  }
}
