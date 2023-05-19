import Foundation

public enum NetworkError: Error, Hashable {
  public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    switch (lhs, rhs) {
    case let (.generic(lhs), .generic(rhs)):
      return (lhs as NSError) == (rhs as NSError)
    case (.noInternetConnection, .noInternetConnection):
      return true
    case (.requestTimedOut, .requestTimedOut):
      return true
    case (.failedToEncode, .failedToEncode):
      return true
    case (.serverResponseNotValid, .serverResponseNotValid):
      return true
    case (.forbidden, .forbidden):
      return true
    case (.resourceNotFound, .resourceNotFound):
      return true
    case let (.clientError(lhs), .clientError(rhs)):
      return lhs == rhs
    case let (.serverError(lhs), .serverError(rhs)):
      return lhs == rhs
    case let (.failedToDecode(lhs), .failedToDecode(rhs)):
      return lhs == rhs
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case let .generic(error):
      hasher.combine("generic")
      hasher.combine(error as NSError)

    case .noInternetConnection:
      hasher.combine("noInternetConnection")

    case .requestTimedOut:
      hasher.combine("requestTimedOut")

    case .failedToEncode:
      hasher.combine("failedToEncode")
    case .serverResponseNotValid:
      hasher.combine("serverResponseNotValid")

    case .forbidden:
      hasher.combine("forbidden")

    case .resourceNotFound:
      hasher.combine("resourceNotFound")

    case let .clientError(code):
      hasher.combine("clientError")
      hasher.combine(code)

    case let .serverError(code):
      hasher.combine("serverError")
      hasher.combine(code)

    case let .failedToDecode(data):
      hasher.combine("failedToDecode")
      hasher.combine(data)
    }
  }

  case generic(Error)
  case noInternetConnection
  case requestTimedOut
  case failedToEncode
  case serverResponseNotValid
  case forbidden
  case resourceNotFound
  case clientError(Int)
  case serverError(Int)
  case failedToDecode(Data)
}
