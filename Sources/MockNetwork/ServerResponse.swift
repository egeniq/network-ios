import Foundation

public struct ServerResponse: Hashable {
  public init(statusCode: HTTPStatusCode = .code200, httpVersion: HTTPVersion = .onePointOne, data: Data? = nil, headers: [String: String] = [:]) {
    self.statusCode = statusCode
    self.httpVersion = httpVersion
    self.data = data
    self.headers = headers
  }

  /// The desired status code to expect from the request.
  public let statusCode: HTTPStatusCode

  /// The desired http version to include in the response.
  public let httpVersion: HTTPVersion

  /// The expected response data, if any.
  public let data: Data?

  /// Custom headers to add to the mocked response.
  public let headers: [String: String]
}
