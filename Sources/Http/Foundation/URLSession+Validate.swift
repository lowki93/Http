import Foundation
import Combine

extension URLSession.DataTaskPublisher {
    private typealias Output = URLSession.DataTaskPublisher.Output
    
    public func validate() -> some Publisher {
        tryMap { output -> Output in
            try output.response.validate()
            return output
        }
    }
}
