import Foundation

extension Encodable {
    /// Encode the object with provided encoder.
    /// This technique allow to "open" an existential, that is to use it in a context where a generic is expected
    func encoded(with encoder: DataEncoder) throws -> Data {
        try encoder.encode(self)
    }
}

extension Decodable {
    /// Decode data using provided decoder
    /// This technique allow to "open" an existential, that is to use it in a context where a generic is expected
    static func decoded(from data: Data, with decoder: DataDecoder) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }
}
