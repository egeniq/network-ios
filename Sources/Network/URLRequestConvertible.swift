import Foundation

/// An object that can generate a 'URLRequest
protocol URLRequestConvertible {
  /// Generates a `URLRequest`.
  ///
  /// - Returns: a properly formed `URLRequest`
  func urlRequest() throws -> URLRequest
}

extension URL {
  typealias Path = [String]
}
