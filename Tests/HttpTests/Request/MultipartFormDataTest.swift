import XCTest
@testable import Http

class MultipartFormDataTest: XCTestCase {

  let crlf = EncodingCharacters.crlf

  func test_contentType_contains_boudary() {
    let boundary = "boundary"
    let multipart = MultipartFormData(boundary: boundary)

    let expectedContentType = HTTPContentType.multipart(boundary: boundary)
    XCTAssertEqual(multipart.contentType, expectedContentType)
  }

  func test_addData_withoutFileNameAndMimeType_expectOneBodyPart() throws {
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)
    let data = "I'm pjechris, Nice to meet you"
    let name = "data"
    multipart.add(data: Data(data.utf8), name: name)
    let expectedHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name)\"")
    ]

    XCTAssertEqual(multipart.bodyParts.count, 1)

    let bodyPart = try XCTUnwrap(multipart.bodyParts.first)
    XCTAssertEqual(bodyPart.headers, expectedHeaders)
  }

  func test_addData_oneWithoutFileNameAndMimeType_secondWithAllValue_expect2BodyParts() throws {
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)

    let data1 = "Swift"
    let name1 = "swift"
    multipart.add(data: Data(data1.utf8), name: name1)

    let data2 = "Combine"
    let name2 = "combine"
    let fileName2 = "combine.txt"
    let mimeType2 = "text/plain"
    multipart.add(data: Data(data2.utf8), name: name2, fileName: fileName2, mimeType: mimeType2)
    let expectedFirstBodyPartHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name1)\"")
    ]
    let expectedLastBodyPartHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name2)\"; filename=\"\(fileName2)\""),
      Header(name: .contentType, value: mimeType2)
    ]

    XCTAssertEqual(multipart.bodyParts.count, 2)

    let bodyPart1 = try XCTUnwrap(multipart.bodyParts.first)
    XCTAssertEqual(bodyPart1.headers, expectedFirstBodyPartHeaders)

    let bodyPart2 = try XCTUnwrap(multipart.bodyParts.last)
    XCTAssertEqual(bodyPart2.headers, expectedLastBodyPartHeaders)
  }
//
//  func test_encoding_url_bodyPart() throws {
//    let boundary = "boundary"
//    var multipart = MultipartFormData(boundary: boundary)
//
//    let url = try url(forResource: "swift", withExtension: "png")
//    let name = "swift"
//    try multipart.add(url: url, name: name)
//
//    let encodedData = try multipart.encode()
//
//    var expectedData = Data()
//    expectedData.append(Boundary.data(for: .initial, boundary: boundary))
//    expectedData.append(
//      Data((
//        "Content-Disposition: form-data; name=\"\(name)\"; filename=\"swift.png\"\(crlf)"
//          + "Content-Type: image/png\(crlf)\(crlf)"
//      ).utf8)
//    )
//    expectedData.append(try Data(contentsOf: url))
//    expectedData.append(Boundary.data(for: .final, boundary: boundary))
//    XCTAssertEqual(encodedData, expectedData)
//  }
//
//  func test_encoding_url_multipleBodyPart() throws {
//    let boundary = "boundary"
//    var multipart = MultipartFormData(boundary: boundary)
//
//    let url1 = try url(forResource: "swift", withExtension: "png")
//    let name1 = "swift"
//    try multipart.add(url: url1, name: name1)
//
//    let url2 = try url(forResource: "swiftUI", withExtension: "png")
//    let name2 = "swiftUI"
//    try multipart.add(url: url2, name: name2)
//
//    let encodedData = try multipart.encode()
//
//    var expectedData = Data()
//    expectedData.append(Boundary.data(for: .initial, boundary: boundary))
//    expectedData.append(Data((
//        "Content-Disposition: form-data; name=\"\(name1)\"; filename=\"swift.png\"\(crlf)"
//        + "Content-Type: image/png\(crlf)\(crlf)").utf8
//      )
//    )
//    expectedData.append(try Data(contentsOf: url1))
//    expectedData.append(Boundary.data(for: .encapsulated, boundary: boundary))
//    expectedData.append(
//      Data((
//        "Content-Disposition: form-data; name=\"\(name2)\"; filename=\"swiftUI.png\"\(crlf)"
//        + "Content-Type: image/png\(crlf)\(crlf)"
//      ).utf8)
//    )
//    expectedData.append(try Data(contentsOf: url2))
//    expectedData.append(Boundary.data(for: .final, boundary: boundary))
//    XCTAssertEqual(encodedData, expectedData)
//  }
//
//  func test_encoding_varryingType_multipleBodyPart() throws {
//    let boundary = "boundary"
//    var multipart = MultipartFormData(boundary: boundary)
//
//    let data = "I'm pjechris, Nice to meet you"
//    let name1 = "data"
//    multipart.add(data: Data(data.utf8), name: name1)
//
//    let url = try url(forResource: "swift", withExtension: "png")
//    let name2 = "swift"
//    try multipart.add(url: url, name: name2)
//
//    let encodedData = try multipart.encode()
//
//    var expectedData = Data()
//    expectedData.append(Boundary.data(for: .initial, boundary: boundary))
//    expectedData.append(
//      Data((
//        "Content-Disposition: form-data; name=\"\(name1)\"\(crlf)\(crlf)"
//        + data
//      ).utf8)
//    )
//    expectedData.append(Boundary.data(for: .encapsulated, boundary: boundary))
//    expectedData.append(
//      Data((
//        "Content-Disposition: form-data; name=\"\(name2)\"; filename=\"swift.png\"\(crlf)"
//        + "Content-Type: image/png\(crlf)\(crlf)"
//      ).utf8)
//    )
//    expectedData.append(try Data(contentsOf: url))
//    expectedData.append(Boundary.data(for: .final, boundary: boundary))
//    XCTAssertEqual(encodedData, expectedData)
//  }

}
