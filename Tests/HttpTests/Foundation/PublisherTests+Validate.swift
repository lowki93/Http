import XCTest
import Combine
import Http

class PublisherValidateTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables = []
    }
    
    func test_validate_responseIsError_handlerIsDefined_dataIsEmpty_transormerIsNotCalled() throws {
        let output: URLSession.DataTaskPublisher.Output = (data: Data(), response: HTTPURLResponse.notFound)
        let transformer: HTTPErrorHandler = { error, _ in
            XCTFail("transformer should not be called when data is empty")
            return error
        }
        
        Just(output)
            .validate(transformer)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func test_validate_responseIsError_handlerIsDefined_dataIsNotEmpty_itTransformError() throws {
        let customError = CustomError(code: 22, message: "custom message")
        let output: URLSession.DataTaskPublisher.Output = (
            data: try JSONEncoder().encode(customError),
            response: HTTPURLResponse.notFound
        )
        let transformer: HTTPErrorHandler = { error, data in
            return try JSONDecoder().decode(CustomError.self, from: data)
        }
        
        Just(output)
            .validate(transformer)
            .sink(
                receiveCompletion: {
                    guard case let .failure(error) = $0 else {
                        return XCTFail()
                    }
                    
                    XCTAssertEqual(error as? CustomError, customError)
                },
                receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

private struct CustomError: Error, Equatable, Codable {
    let code: Int
    let message: String
}
