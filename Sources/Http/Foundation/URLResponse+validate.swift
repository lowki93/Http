import Foundation

extension URLResponse {

  typealias Output = (data: Data, response: URLResponse)

  static func validate(_ output: Output, with converter: DataErrorConverter? = nil) throws -> Output {
    do {
      try (output.response as? HTTPURLResponse)?.validate()
      return output
    } catch {
      if let _ = error as? HTTPError, let convert = converter, !output.data.isEmpty {
        throw try convert(output.data)
      }

      throw error
    }
  }

}
