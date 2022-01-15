import Foundation

@available(macOS 12.0, iOS 15.0, *)
public struct AsyncSession {

  public typealias AsyncData = (Data, URLResponse)

  let baseURL: URL
  let config: SessionConfiguration
  let asyncUrlRequest: (URLRequest) async throws -> AsyncData

  /// init the class using a `URLSession` instance
  /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
  /// - Parameter configuration: session configuration to use
  /// - Parameter urlSession: `URLSession` instance to use to make requests.
  public init(baseURL: URL, configuration: SessionConfiguration = .init(), urlSession: URLSession) {
    self.init(
      baseURL: baseURL,
      configuration: configuration,
      asyncData: urlSession.asyncData(for:)
    )
  }

  /// init the class with a base url for request
  /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
  /// - Parameter configuration: session configuration to use
  /// - Parameter dataPublisher: publisher used by the class to make http requests. If none provided it default
  /// to `URLSession.asyncData(for:)`
  public init(
      baseURL: URL,
      configuration: SessionConfiguration = .init(),
      asyncData: @escaping (URLRequest) async throws -> AsyncData = { try await URLSession.shared.asyncData(for: $0) }
  ) {
      self.baseURL = baseURL
      self.config = configuration
      self.asyncUrlRequest = asyncData
  }

  /// Return `Output` data
  ///
  /// The request is validated and decoded appropriately on success.
  /// - Returns: return the  Output on success, otherwise it's throwan  error
  public func request<Output: Decodable>(for request: Request<Output>) async throws -> Output {
    let response = try await asyncData(for: request)
    let result = Result {
      try config.interceptor.adaptOutput(
        try config.decoder.decode(Output.self, from: response.data),
        for: response.request
      )
    }
    log(result, for: request)
    return try result.get()
  }

  /// Performing request which has no return value
  public func request(for request: Request<Void>) async throws {
    _ = try await asyncData(for: request)
    log(.success(()), for: request)
  }

}

@available(macOS 12.0, iOS 15.0, *)
extension AsyncSession {
  private func asyncData<Output>(for request: Request<Output>) async throws -> Response<Output> {
    let adaptedRequest = config.interceptor.adaptRequest(request)

    let urlRequest = try adaptedRequest.toURLRequest(base: baseURL, encoder: config.encoder)
      .accepting(config.decoder)

    do {
      var response = try await asyncUrlRequest(urlRequest)
      response = try validate(output: response, with: config.errorDecoder)
      let responseOuput = Response(data: response.0, request: adaptedRequest)
      return responseOuput
    } catch {
      logFailure(error, for: adaptedRequest)
      return try await rescue(error: error, request: request)
    }
  }

  private func validate(output: AsyncData, with converter: DataErrorConverter? = nil) throws -> AsyncData {
    try URLResponse.validate((output.0, output.1), with: converter)
  }

  /// log a request completion
  private func logFailure<Output>(_ error: Error, for request: Request<Output>) {
    config.interceptor.receivedResponse(.failure(error), for: request)
  }

  private func log<Output>(_ response: Result<Output, Error>, for request: Request<Output>) {
    config.interceptor.receivedResponse(response, for: request)
  }

  /// try to rescue an error while making a request and retry it when rescue suceeded
  private func rescue<Output>(error: Error, request: Request<Output>) async throws -> Response<Output> {
    guard let rescue = config.interceptor.asyncRescueRequest(request, error: error) else {
      throw error
    }

    try await rescue()
    return try await asyncData(for: request)
  }

}

private struct Response<Output> {
  let data: Data
  let request: Request<Output>
}
