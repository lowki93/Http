import Foundation
import Combine

/// Primary class of the library used to perform http request using `Request` objects
public class Session {
    /// Data returned by a http request
    public typealias Data = URLSession.DataTaskPublisher.Output
    
    /// a Publisher emitting `Data`
    public typealias DataPublisher = AnyPublisher<Data, Error>
    
    let baseURL: URL
    let encoder: DataContentEncoder
    let decoder: DataContentDecoder
    let requestPublisher: (URLRequest) -> DataPublisher

    /// init the class using a `URLSession` instance
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter encoder: the encoder to use for request bodies
    /// - Parameter decoder: the decoder used to decode http responses
    /// - Parameter urlSession: `URLSession` instance to use to make requests. 
    public convenience init(
      baseURL: URL,
      encoder: DataContentEncoder,
      decoder: DataContentDecoder,
      urlSession: URLSession
    ) {
      self.init(baseURL: baseURL, encoder: encoder, decoder: decoder, dataPublisher: urlSession.dataPublisher(for:))
    }
    
    /// init the class with a base url for request
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter encoder: the encoder to use for request bodies
    /// - Parameter decoder: the decoder used to decode http responses
    /// - Parameter dataPublisher: publisher used by the class to make http requests. If none provided it default
    /// to `URLSession.dataPublisher(for:)`
    public init(
        baseURL: URL,
        encoder: DataContentEncoder = JSONEncoder(),
        decoder: DataContentDecoder = JSONDecoder(),
        dataPublisher: @escaping (URLRequest) -> DataPublisher = { URLSession.shared.dataPublisher(for: $0) }
    ) {
        self.baseURL = baseURL
        self.encoder = encoder
        self.decoder = decoder
        self.requestPublisher = dataPublisher
    }
    
    /// Return a publisher performing request and returning `Output` data
    ///
    /// The request is validated and decoded appropriately on success.
    /// - Returns: a Publisher emitting Output on success, an error otherwise
    public func publisher<Output: Decodable>(for request: Request<Output>) -> AnyPublisher<Output, Error> {
        dataPublisher(for: request)
            .tryMap { try self.decoder.decode(Output.self, from: $0.data) }
            .eraseToAnyPublisher()
    }

    /// Return a publisher performing request which has no return value
    public func publisher(for request: Request<Void>) -> AnyPublisher<Void, Error> {
      dataPublisher(for: request)
          .map { _ in () }
          .eraseToAnyPublisher()
    }
}

extension Session {
    private func dataPublisher<Output>(for request: Request<Output>) -> DataPublisher {
        do {
            return requestPublisher(try request.toURLRequest(base: baseURL, encoder: encoder))
                .validate()
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
}
