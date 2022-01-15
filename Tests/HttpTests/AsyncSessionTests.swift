import XCTest
import Http

// To Delete
import Combine

@available(macOS 12.0, iOS 15.0, *)
class AsyncSessionTests: XCTestCase {

  let baseURL = URL(string: "https://sessionTests.io")!
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  private var interceptor: InterceptorMock!

  override func setUp() {
    interceptor = InterceptorMock()
  }

  func test_request_responseIsValid_DecodeOutputIsReturned() async throws {
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(data: { (data: data, response: .success) })

    let result = try await session.request(for: Request.test())

    XCTAssertEqual(result, expectedResponse)
  }

  func test_request_responseIsValid_itCallInterceptorAdaptRequest() async throws {
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(data: { (data: data, response: .success) })

    _ = try await session.request(for: Request.test())

    XCTAssertTrue(interceptor.adaptOutputCalled)
  }

  func test_request_responseIsValid_itCallInterceptorAdaptOutput() async throws {
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(data: { (data: data, response: .success) })

    _ = try await session.request(for: Request.test())

    XCTAssertTrue(interceptor.adaptOutputCalled)
  }

  func test_request_responseIsValid_adaptResponseThrow_itReturnAnError() async throws {
    let output = Content(value: "adapt throw")
    interceptor.adaptResponseMock = { _, _ in
        throw CustomError()
    }
    let data = try JSONEncoder().encode(output)
    let session = sesssionStub(data: { (data: data, response: .success) })

    do {
      _ = try await session.request(for: Request.test())
      XCTFail("Expected to throw while awaiting, but succeeded")
    } catch {
      XCTAssertEqual(error as? CustomError, CustomError())
    }
  }

  func test_request_outputIsDecoded_itCallInterceptorReceivedResponse() async throws {
    let output = Content(value: "hello")
    let data = try JSONEncoder().encode(output)
    let session = sesssionStub(data: { (data: data, response: .success) })
    let expectation = XCTestExpectation()

    interceptor.receivedResponseMock = { response, _ in
        let response = response as? Result<Content, Error>

        XCTAssertEqual(try? response?.get(), output)
        expectation.fulfill()
    }

    _ = try await session.request(for: Request.test())

    XCTAssertTrue(interceptor.receivedResponseCalled)

    wait(for: [expectation], timeout: 1)
  }

  /// helper to create a session for testing
  private func sesssionStub(data: @escaping () -> AsyncSession.AsyncData) -> AsyncSession {
    let config = SessionConfiguration(encoder: encoder, decoder: decoder, interceptors: .init(arrayLiteral: interceptor))

    return AsyncSession(baseURL: baseURL, configuration: config, asyncData: { _ in
      data()
    })
  }

}

private enum Endpoint: String, Path {
  case test
}

private struct Content: Codable, Equatable {
  let value: String
}

private struct CustomError: Error, Equatable {

}

private extension Request {
  static func test() -> Self where Output == Content {
    .get(Endpoint.test)
  }

  static func void() -> Self where Output == Void {
    .get(Endpoint.test)
  }
}
