import Foundation

/// An empty codable object.
public struct Empty: Codable {
  /// Static `Empty` instance used for all `Empty` responses.
  static let value = Empty()
}
