import Foundation

public struct NetworkExchange: Hashable {
  public init(urlRequest: URLRequest, response: ServerResponse? = nil, error: MockNetworkError? = nil) {
    self.urlRequest = urlRequest
    self.response = response
    self.error = error
  }

  /// The `URLRequest` associated to the request.
  let urlRequest: URLRequest

  /// The mocked response inside of the exchange.
  let response: ServerResponse?

  /// An optional error
  let error: MockNetworkError?

  /// The expected `HTTPURLResponse`.
  var urlResponse: HTTPURLResponse? {
    guard let response = response else {
      return nil
    }
    return HTTPURLResponse(
      url: urlRequest.url!,
      statusCode: response.statusCode.rawValue,
      httpVersion: response.httpVersion.rawValue,
      headerFields: response.headers
    )
  }
}
