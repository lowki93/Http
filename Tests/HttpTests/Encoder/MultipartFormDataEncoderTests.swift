import XCTest
@testable import Http

class MultipartFormDataEncoderTests: XCTestCase {

  let crlf = EncodingCharacters.crlf

  func test_encode_multipartAddData_bodyPart() throws {
    // Given
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)

    let data = "I'm pjechris, Nice to meet you"
    let name = "data"
    multipart.add(data: Data(data.utf8), name: name)

    let expectedString = (
      Boundary.string(for: .initial, boundary: boundary)
        + "Content-Disposition: form-data; name=\"\(name)\"\(crlf)\(crlf)"
        + data
        + Boundary.string(for: .final, boundary: boundary)
    )
    let expectedData = Data(expectedString.utf8)
    let encoder = MultipartFormDataEncoder(body: multipart)

    // When
    let encodedData = try encoder.encode()

    // Then
    XCTAssertEqual(encodedData, expectedData)
  }


  func test_encoding_data_multipleBodyPart() throws {
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)

    let data1 = "Swift"
    let name1 = "swift"
    multipart.add(data: Data(data1.utf8), name: name1)

    let data2 = "Combine"
    let name2 = "combine"
    let mimeType2 = "text/plain"
    multipart.add(data: Data(data2.utf8), name: name2, mimeType: mimeType2)

    let expectedString = (
      Boundary.string(for: .initial, boundary: boundary)
        + "Content-Disposition: form-data; name=\"\(name1)\"\(crlf)\(crlf)"
        + data1
        + Boundary.string(for: .encapsulated, boundary: boundary)
        + "Content-Disposition: form-data; name=\"\(name2)\"\(crlf)"
        + "Content-Type: \(mimeType2)\(crlf)\(crlf)"
        + data2
        + Boundary.string(for: .final, boundary: boundary)
    )
    let expectedData = Data(expectedString.utf8)
    let encoder = MultipartFormDataEncoder(body: multipart)

    let encodedData = try encoder.encode()


    XCTAssertEqual(encodedData, expectedData)
  }

}
