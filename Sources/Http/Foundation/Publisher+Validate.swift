#if canImport(Combine)

import Foundation
import Combine

/// A function converting data when a http error occur into a custom error
public typealias DataErrorConverter = (Data) throws -> Error

extension Publisher where Output == URLSession.DataTaskPublisher.Output {    
    public func validate(_ converter: DataErrorConverter? = nil) -> AnyPublisher<Output, Error> {
        tryMap { output in
            do {
                try (output.response as? HTTPURLResponse)?.validate()
                return output
            }
            catch {
                if let _ = error as? HTTPError, let convert = converter, !output.data.isEmpty {
                    throw try convert(output.data)
                }
                
                throw error
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
