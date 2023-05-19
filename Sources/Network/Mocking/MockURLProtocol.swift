import Foundation

/// A subclass of `URLProtocol` that allows us to mock network exchanges to simulate different request/response combos.
public class MockURLProtocol: URLProtocol {

  /// The set containing all the requests we would want to mock.
  public static var mockRequests: () -> Set<NetworkExchange> = { [] }

  /// The delay to simulate before returning an answer
  /// The value represents the numbers of seconds
  ///
  /// Defaults to 0
  public static var delay: () -> Int = { 0 }

  public override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  public override func startLoading() {
    // Tells the client that the  implementation has finished loading.
    defer {
      client?.urlProtocolDidFinishLoading(self)
    }

    sleep(UInt32(Self.delay()))

    // swiftlint: disable:next unowned_variable_capture
    let foundRequest = Self.mockRequests().first { [unowned self] in
      request.url?.path == $0.urlRequest.url?.path &&
      request.httpMethod == $0.urlRequest.httpMethod
    }

    if let error = foundRequest?.error {
      // The fallback value is custom made for testing.
      client?.urlProtocol(self, didFailWithError: error.urlError ?? NSError (domain: "MockURLProtocol", code: 0))
      return
    }

    guard let mockExchange = foundRequest else {
      client?.urlProtocol(self, didFailWithError: MockNetworkError.routeNotFound)
      return
    }

    if let data = mockExchange.response?.data {
      client?.urlProtocol (self, didLoad: data)
    }

    guard let response = mockExchange.urlResponse else {
      return
    }

    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
  }

  public override func stopLoading() {}
}
