import Foundation

public extension URLSession.DataTaskPublisher {
    func validate() -> some Publisher {
        tryMap {
            try $0.response.validate()
            return $0
        }
    }
}
