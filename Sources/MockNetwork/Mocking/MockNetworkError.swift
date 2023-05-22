import Foundation

public enum MockNetworkError: Error, Hashable, Equatable {
  /// Equivalent to `URLError(.notConnectedToInternet)`
  case notConnectedToInternet

  /// Equivalent to `URLError(.timedOut)`
  case requestTimedOut

  /// Equivalent to `URLError(.resourceUnavailable)`
  case routeNotFound

  /// Equivalent to `URLError( .cannotFindHost)`
  case hostNotFound

  /// A custom error with a `nil` `URLError` value.
  case notURLError

  /// The `URLError` value of the case.
  var urlError: URLError? {
    switch self {
    case .notConnectedToInternet:
      return URLError(.notConnectedToInternet)
    case .requestTimedOut:
      return URLError(.timedOut)
    case .routeNotFound:
      return URLError(.resourceUnavailable)
    case .hostNotFound:
      return URLError(.cannotFindHost)
    case .notURLError:
      return nil
    }
  }
}
