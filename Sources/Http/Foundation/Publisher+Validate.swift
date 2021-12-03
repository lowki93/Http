#if canImport(Combine)

import Foundation
import Combine

extension Publisher where Output == URLSession.DataTaskPublisher.Output {    
    public func validate() -> AnyPublisher<Output, Error> {
        tryMap { output in
            try (output.response as? HTTPURLResponse)?.validate()
            return output
        }
        .eraseToAnyPublisher()
    }
}

#endif
