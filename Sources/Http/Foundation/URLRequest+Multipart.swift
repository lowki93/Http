import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
  mutating func multipartBody(_ body: MultipartFormData) throws {
    httpBody = try body.encode()
    setHeader(.contentType, value: body.contentType.value)
  }
}
