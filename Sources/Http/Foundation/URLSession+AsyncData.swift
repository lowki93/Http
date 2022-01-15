import Foundation

@available(macOS 12.0, iOS 15.0, *)
extension URLSession {
  public func asyncData(for request: URLRequest) async throws -> AsyncSession.AsyncData {
    try await data(for: request)
  }
}
