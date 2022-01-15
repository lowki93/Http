import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
  func encodedBody(_ body: Body, encoder: ContentDataEncoder) throws -> Self {
    var request = self

    try request.encodeBody(body, encoder: encoder)

    return request
  }

  /// Use a `Encodable` object as request body and set the "Content-Type" header associated to the encoder
  mutating func encodeBody(_ body: Body, encoder: ContentDataEncoder) throws {
    switch body {
    case .encodable(let data): try bodyEncodable(body: data, with: encoder)
    case .multipart(let multipart): try bodyMultipart(body: multipart)
    }
  }

  private mutating func bodyEncodable(body: Encodable, with encoder: ContentDataEncoder) throws {
    httpBody = try body.encoded(with: encoder)
    setHeader(.contentType, value: type(of: encoder).contentType.value)
  }

  private mutating func bodyMultipart(body: MultipartFormData) throws {
    httpBody = try body.encode()
    setHeader(.contentType, value: body.contentType.value)
  }

  func accepting(_ decoder: ContentDataDecoder) -> Self {
    var request = self

    request.accept(decoder)

    return request
  }

  /// Set the request header type accept appropriate to work with the decoder
  mutating func accept(_ decoder: ContentDataDecoder) {
    setHeader(.accept, value: type(of: decoder).contentType.value)
  }

  /// set a header on the request using `HTTPHeader`
  mutating func setHeader(_ header: HTTPHeader, value: String?) {
    setValue(value, forHTTPHeaderField: header.key)
  }
}
