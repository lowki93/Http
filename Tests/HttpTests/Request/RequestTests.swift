import XCTest
@testable import Http

class RequestTests: XCTestCase {
    let baseURL = URL(string: "https://google.com")!
    
    enum TestEndpoint: String, Path {
        case test
    }
    
    func test_urlFor_itAppendPathToURL() throws {
        XCTAssertEqual(
            try Request<Void>.get(TestEndpoint.test).url(for: baseURL).absoluteString,
            "\(baseURL.absoluteString)/test"
        )
    }
    
    func test_toURLRequest_itSetHttpMethod() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: nil)
            .toURLRequest(base: baseURL, encoder: JSONEncoder())
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_toURLRequest_itEncodeBody() throws {
      let request = try Request<Void>.post(TestEndpoint.test, body: .encodable(Body()))
            .toURLRequest(base: baseURL, encoder: JSONEncoder())
        
        XCTAssertEqual(request.httpBody, try JSONEncoder().encode(Body()))
    }
    
    func test_toURLRequest_itFillDefaultHeaders() throws {
      let request = try Request<Void>.post(TestEndpoint.test, body: .encodable(Body()))
            .toURLRequest(base: baseURL, encoder: JSONEncoder())
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

}

private struct Body: Encodable {
    
}
