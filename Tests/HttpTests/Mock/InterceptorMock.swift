import Foundation
import Combine
import Http

class InterceptorMock: Interceptor {

  var adaptRequestCalled: Bool = false
  func adaptRequest<Output>(_ request: Request<Output>) -> Request<Output> {
    adaptRequestCalled = true
    return request
  }

  var rescueRequestCalled = false
  var rescueRequestErrorMock: ((Error) -> AnyPublisher<Void, Error>?)?
  func rescueRequest<Output>(_ request: Request<Output>, error: Error) -> AnyPublisher<Void, Error>? {
    rescueRequestCalled = true
    return rescueRequestErrorMock?(error)
  }

  @available(macOS 12.0, iOS 15.0, *)
  func rescueRequest<Output>(_ request: Request<Output>, error: Error) -> (() async throws -> ())? {
    return nil
  }

  var adaptOutputCalled: Bool = false
  var adaptResponseMock: ((Any, Any) throws -> Any)?
  func adaptOutput<Output>(_ output: Output, for request: Request<Output>) throws -> Output {
    adaptOutputCalled = true
    guard let mock = adaptResponseMock else {
      return output
    }

    return try mock(output, request) as! Output
  }

  var receivedResponseCalled = false
  var receivedResponseMock: ((Any, Any) -> ())?
  func receivedResponse<Output>(_ result: Result<Output, Error>, for request: Request<Output>) {
    receivedResponseCalled = true
    receivedResponseMock?(result, result)
  }
}
