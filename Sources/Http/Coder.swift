import Foundation

/// A encoder suited to encode to Data
public protocol DataEncoder {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

/// A decoder suited to decode Data
public protocol DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

/// A `DataEncoder` providing a `ContentType`
public typealias DataContentEncoder = DataEncoder & ContentType

/// A `DataDecoder` providing a `ContentType`
public typealias DataContentDecoder = DataDecoder & ContentType
