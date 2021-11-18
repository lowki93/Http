import Foundation

public extension URLResponse {
    /// check whether a response is valid or not
    @objc
    func validate() throws { }
}

public extension HTTPURLResponse {
    @objc
    override func validate() throws {
        guard (200..<300).contains(statusCode) else {
            throw HttpError(statusCode: statusCode)
        }
    }
}
