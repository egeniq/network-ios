import Foundation

/// The list of supported authorization types
public enum AuthorizationType {
  /// No authorization header is required.
  case none

  /// The Authorization header required a token (also known as resource token).
  case token(_ token: String)
}
