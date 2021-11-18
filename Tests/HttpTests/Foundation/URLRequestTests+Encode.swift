import XCTest
import Http

class URLRequestEncodeTests: XCTest {
    
    func test_encodedBody_itSetContentTypeHeader() throws {
        let body: [String:String] = [:]
        let request = try URLRequest(url: URL(string: "/")!)
            .encodedBody(body, encoder: JSONEncoder())
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], JSONEncoder().contentType)
    }
}
