import Foundation

/// An object capable to decode 'Data' into a 'Decodable object.
public protocol DataDecoder {
  /// Decodes a top-level value of the given type from the given data representation.
  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

extension JSONDecoder: DataDecoder {}
