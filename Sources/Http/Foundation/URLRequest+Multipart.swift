import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
  mutating func multipartBody(_ body: MultipartFormData) throws {
    let multipartEncode = MultipartFormDataEncoder(body: body)
    httpBody = try multipartEncode.encode()
    setHeader(.contentType, value: body.contentType.value)
  }
}
