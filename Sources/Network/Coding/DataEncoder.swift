import Foundation

/// An object capable to encode an `Encodable` object into 'Data
public protocol DataEncoder {
  /// Encodes the given top-level value and returns its representation.
  func encode<T>(_ value: T) throws -> Data where T: Encodable
}

extension JSONEncoder: DataEncoder {}
