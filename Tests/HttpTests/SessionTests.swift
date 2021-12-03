import XCTest
import Combine
import Http

class SessionTests: XCTestCase {
  let baseURL = URL(string: "https://sessionTests.io")!
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  var cancellables: Set<AnyCancellable> = []

  override func tearDown() {
    cancellables.removeAll()
  }

  func test_publisherFor_responseIsValid_decodedOutputIsReturned() throws {
    let response = Content(value: "response")
    let session = Session(baseURL: baseURL, encoder: encoder, decoder: decoder) { _ in
      Just((data: try! JSONEncoder().encode(response), response: .success))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    let expectation = XCTestExpectation()

    session.publisher(for: Request.test())
      .sink(
        receiveCompletion: { _ in },
        receiveValue: {
          XCTAssertEqual($0, response)
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }
}

private enum Endpoint: String, Path {
  case test
}

private struct Content: Codable, Equatable {
  let value: String
}

private extension Request {
  static func test() -> Self where Output == Content {
    .get(Endpoint.test)
  }
}
