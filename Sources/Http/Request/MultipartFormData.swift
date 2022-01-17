import Foundation
import UniformTypeIdentifiers

typealias Header = (name: HTTPHeader, value: String)

enum EncodingCharacters {
  static let crlf = "\r\n"
}

enum Boundary {

  enum `Type` {
    case initial
    case encapsulated
    case final
  }

  static func random() -> String {
    UUID().uuidString
  }

  static func string(for type: Boundary.`Type`, boundary: String) -> String {
    switch type {
    case .initial:
      return "--\(boundary)\(EncodingCharacters.crlf)"
    case .encapsulated:
      return "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
    case .final:
      return "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
    }
  }

  static func data(for type: Boundary.`Type`, boundary: String) -> Data {
    let boundaryText = Self.string(for: type, boundary: boundary)

    return Data(boundaryText.utf8)
  }
}

class BodyPart {

  let headers: [Header]
  let stream: InputStream
  let length: Int
  var hasInitialBoundary = false
  var hasFinalBoundary = false

  //
  // The optimal read/write buffer size in bytes for input and output streams is 1024 (1KB). For more
  // information, please refer to the following article:
  //   - https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Streams/Articles/ReadingInputStreams.html
  //
  private let streamBufferSize = 1024

  init(headers: [Header], stream: InputStream, length: Int) {
    self.headers = headers
    self.stream = stream
    self.length = length
  }

  func encode(with boundary: String) throws -> Data {
    var encoded = Data()

    if hasInitialBoundary {
      encoded.append(Boundary.data(for: .initial, boundary: boundary))
    } else {
      encoded.append(Boundary.data(for: .encapsulated, boundary: boundary))
    }

    encoded.append(try encodeHeader())
    encoded.append(try encodeStream())

    if hasFinalBoundary {
      encoded.append(Boundary.data(for: .final, boundary: boundary))
    }

    return encoded
  }

  private func encodeHeader() throws -> Data {
    let headerText = headers.map { "\($0.name.key): \($0.value)\(EncodingCharacters.crlf)" }
      .joined()
      + EncodingCharacters.crlf

    return Data(headerText.utf8)
  }

  private func encodeStream() throws -> Data {
    var encoded = Data()

    stream.open()
    defer { stream.close() }

    while stream.hasBytesAvailable {
      var buffer = [UInt8](repeating: 0, count: streamBufferSize)
      let bytesRead = stream.read(&buffer, maxLength: streamBufferSize)

      if let error = stream.streamError {
        throw BodyPart.Error.inputStreamReadFailed(error.localizedDescription)
      }

      if bytesRead > 0 {
        encoded.append(buffer, count: bytesRead)
      } else {
        break
      }
    }

    guard encoded.count == length else {
      throw BodyPart.Error.unexpectedInputStreamLength(expected: length, bytesRead: encoded.count)
    }

    return encoded
  }

}

/// Constructs `multipart/form-data` for uploads within an HTTP or HTTPS body.
/// We encode the data directly in memory. It's very efficient, but can lead to memory issues if the dataset is too large (eg: a Video)
///
/// `Warning`: A Second approch to encode bigger dataset will be addes later

public struct MultipartFormData {

  private let boundary: String
  private let fileManager: FileManager
  private var bodyParts = [BodyPart]()

  var contentType: HTTPContentType {
    .multipart(boundary: boundary)
  }

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - fileManager: `FileManager` to use for file operation, if needed
  ///   - boundary: `String` used to separate body parts
  public init(fileManager: FileManager = .default, boundary: String? = nil) {
    self.fileManager = fileManager
    self.boundary = boundary ?? Boundary.random()
  }

  /// Creates a body part from the file and add it to the instance
  ///
  /// The body part data will be encode by using this format:
  ///
  /// - `Content-Disposition: form-data; name=#{name}; filename=#{generated filename}` (HTTPHeader)
  /// - `Content-Type: #{generated mimeType}` (HTTPHeader)
  /// - Encoded file data
  /// - Multipart form boundary
  ///
  /// The filename in the `Content-Disposition` HTTPHeader is generated from the last path component of the `fileURL`.
  /// The `Content-Type` HTTPHeader MIME type is generated by mapping the `fileURL` extension to the system associated MIME type.
  ///
  /// - Parameters:
  ///   - url: `URL` of the file to encoding into the instance
  ///   - name: `String` associated to the `Content-Disposition` HTTPHeader
  public mutating func add(url: URL, name: String) throws {
    let fileName = url.lastPathComponent
    let mimeType = mimeType(from: url)

    try add(url: url, name: name, fileName: fileName, mimeType: mimeType)
  }

  /// Creates a body part from the file and add it to the instance
  ///
  /// The body part data will be encode by using this format:
  ///
  /// - `Content-Disposition: form-data; name=#{name}; filename=#{generated filename}` (HTTPHeader)
  /// - `Content-Type: #{generated mimeType}` (HTTPHeader)
  /// - Encoded file data
  /// - Multipart form boundary
  ///
  /// The filename in the `Content-Disposition` HTTPHeader is generated from the last path component of the `fileURL`.
  /// The `Content-Type` HTTPHeader MIME type is generated by mapping the `fileURL` extension to the system associated MIME type.
  ///
  /// - Parameters:
  ///   - url: `URL` of the file to encoding into the instance
  ///   - name: `String` associated to the `Content-Disposition` HTTPHeader
  ///   - fileName: `String` associated to the `Content-Disposition` HTTPHeader
  ///   - mimeType: `String` associated to the `Content-Type` HTTPHeader
  public mutating func add(url: URL, name: String, fileName: String, mimeType: String) throws {
    let headers = defineBodyPartHeader(name: name, fileName: fileName, mimeType: mimeType)

    guard let fileSize = try fileManager.attributesOfItem(atPath: url.path)[.size] as? NSNumber else {
      throw MultipartFormData.Error.fileSizeNotAvailable(url)
    }

    let length = fileSize.intValue

    guard let stream = InputStream(url: url) else {
      throw MultipartFormData.Error.inputStreamCreationFailed(url)
    }

    bodyParts.append(BodyPart(headers: headers, stream: stream, length: length))
  }

  /// Creates a body part from the data and add it to the instance.
  ///
  /// The body part data will be encoded  by using this:
  ///
  /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTPHeader)
  /// - `Content-Type: #{mimeType}` (HTTPHeader)
  /// - Encoded file data
  /// - Multipart form boundary
  ///
  /// - Parameters:
  ///   - data:     `Data` to encoding into the instance.
  ///   - name:     Name associated to the `Data` in the `Content-Disposition` HTTPHeader.
  ///   - fileName: Filename associated to the `Data` in the `Content-Disposition` HTTPHeader.
  ///   - mimeType: MIME type associated to the data in the `Content-Type` HTTPHeader.
  public mutating func add(data: Data, name: String, fileName: String? = nil, mimeType: String? = nil) {
    let headers = defineBodyPartHeader(name: name, fileName: fileName, mimeType: mimeType)
    let stream = InputStream(data: data)
    let length = data.count

    bodyParts.append(BodyPart(headers: headers, stream: stream, length: length))
  }

  func encode() throws -> Data {
    var encoded = Data()

    bodyParts.first?.hasInitialBoundary = true
    bodyParts.last?.hasFinalBoundary = true

    for bodyPart in bodyParts {
      encoded.append(try bodyPart.encode(with: boundary))
    }

    return encoded
  }

  private func defineBodyPartHeader(name: String, fileName: String?, mimeType: String?) -> [Header] {
    var headers = [Header]()
    var disposition = "form-data; name=\"\(name)\""

    if let fileName = fileName {
      disposition += "; filename=\"\(fileName)\""
    }

    headers.append((.contentDisposition, disposition))

    if let mimeType = mimeType {
      headers.append((.contentType, mimeType))
    }

    return headers
  }

  private func mimeType(from url: URL) -> String {
    guard let type = UTType(filenameExtension: url.pathExtension), let mime = type.preferredMIMEType else {
      return "application/octet-stream"
    }
    return mime
  }

}

extension BodyPart {

  enum Error: Swift.Error {
    case inputStreamReadFailed(String)
    case unexpectedInputStreamLength(expected: Int, bytesRead: Int)
  }

}


public extension MultipartFormData {

  enum Error: Swift.Error {
    case fileSizeNotAvailable(URL)
    case inputStreamCreationFailed(URL)
  }

}
