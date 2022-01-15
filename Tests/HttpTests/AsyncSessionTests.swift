import XCTest
import Http

// To Delete
import Combine

@available(macOS 12.0, iOS 15.0, *)
class AsyncSessionTests: XCTestCase {

  let baseURL = URL(string: "https://sessionTests.io")!
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  private var interceptor: AsyncInterceptorMock!

  override func setUp() {
    interceptor = AsyncInterceptorMock()
  }

  func test_request_responseIsValid_DecodeOutputIsReturned() async throws {
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(interceptor: [interceptor], data: { (data: data, response: .success) })

    let result = try await session.request(for: Request.test())

    XCTAssertEqual(result, expectedResponse)
  }

  func test_request_responseIsValid_itCallInterceptorAdaptRequest() async throws {
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(interceptor: [interceptor], data: { (data: data, response: .success) })

    _ = try await session.request(for: Request.test())

    XCTAssertTrue(interceptor.adaptOutputCalled)
  }

  func test_request_responseIsValid_itCallInterceptorAdaptOutput() async throws {
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(interceptor: [interceptor], data: { (data: data, response: .success) })

    _ = try await session.request(for: Request.test())

    XCTAssertTrue(interceptor.adaptOutputCalled)
  }

  func test_request_responseIsValid_adaptResponseThrow_itReturnAnError() async throws {
    let output = Content(value: "adapt throw")
    interceptor.adaptResponseMock = { _, _ in
        throw CustomError()
    }
    let data = try JSONEncoder().encode(output)
    let session = sesssionStub(interceptor: [interceptor], data: { (data: data, response: .success) })

    do {
      _ = try await session.request(for: Request.test())
      XCTFail("Expected to throw while awaiting, but succeeded")
    } catch {
      XCTAssertEqual(error as? CustomError, CustomError())
    }
  }

  func test_request_rescue_rescueIsSuccess_itRetryRequest() async throws {
    var isRescue = false
    let expectedResponse = Content(value: "response")
    let data = try JSONEncoder().encode(expectedResponse)
    let session = sesssionStub(
      interceptor: [interceptor],
      data: { (data: data, response: isRescue ? .success : .unauthorized) }
    )

    interceptor.asyncRescueRequestMock = {
      isRescue.toggle()
      return try await session.request(for: Request.rescue())
    }

    let result = try await session.request(for: Request.test())

    XCTAssertTrue(isRescue)
    XCTAssertEqual(result, expectedResponse)
  }

  func test_request_rescue_with2Interceptor_firstSuccess_secondThrowAnError() async throws {
    let expectedError = HTTPError.badGateway
    var isRescue1 = false
    var isRescue2 = false
    let output = Content(value: "response")
    let interceptor2 = AsyncInterceptorMock()
    let data = try JSONEncoder().encode(output)
    let session = sesssionStub(
      interceptor: [interceptor, interceptor2],
      data: { (data: data, response: isRescue1 ? .success : .unauthorized) }
    )

    interceptor.asyncRescueRequestMock = {
      isRescue1.toggle()
      return try await session.request(for: Request.rescue())
    }
    interceptor2.asyncRescueRequestMock = {
      isRescue2.toggle()
      throw expectedError
    }

    do {
      _ = try await session.request(for: Request.test())
      XCTFail("Expected to throw while awaiting, but succeeded")
    } catch {
      XCTAssertTrue(isRescue1)
      XCTAssertTrue(isRescue2)
      XCTAssertEqual(error as? HTTPError, expectedError)
    }
  }

  func test_request_outputIsDecoded_itCallInterceptorReceivedResponse() async throws {
    let output = Content(value: "hello")
    let data = try JSONEncoder().encode(output)
    let session = sesssionStub(interceptor: [interceptor], data: { (data: data, response: .success) })
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
  private func sesssionStub(interceptor: CompositeInterceptor = [], data: @escaping () -> AsyncSession.AsyncData) -> AsyncSession {
    let config = SessionConfiguration(encoder: encoder, decoder: decoder, interceptors: interceptor)

    return AsyncSession(baseURL: baseURL, configuration: config, asyncData: { _ in
      data()
    })
  }

}

private enum Endpoint: String, Path {
  case test
  case rescue
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
  static func rescue() -> Self where Output == Void {
    .get(Endpoint.test)
  }

  static func void() -> Self where Output == Void {
    .get(Endpoint.test)
  }
}
