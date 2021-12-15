#if canImport(Combine)

import Foundation
import Combine

/// A function converting a HttpError in a custom Error
public typealias HTTPErrorHandler = (HttpError, Data) throws -> Error

extension Publisher where Output == URLSession.DataTaskPublisher.Output {    
    public func validate(_ transformer: HTTPErrorHandler? = nil) -> AnyPublisher<Output, Error> {
        tryMap { output in
            do {
                try (output.response as? HTTPURLResponse)?.validate()
                return output
            }
            catch {
                if let transform = transformer, let error = error as? HttpError, !output.data.isEmpty {
                    throw try transform(error, output.data)
                }
                
                throw error
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
