import Foundation

public enum HTTPStatusCode: Int {
  /// OK
  case code200 = 200

  /// Unauthorized
  case code401 = 401

  /// FORBIDDEN
  case code403 = 403

  /// NOT FOUND
  case code404 = 404

  /// INTERNAL SERVER ERROR
  case code500 = 500
}
