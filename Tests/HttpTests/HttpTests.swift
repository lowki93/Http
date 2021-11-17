    import XCTest
    @testable import Http

    final class HttpTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            XCTAssertEqual(Http().text, "Hello, World!")
        }
    }
