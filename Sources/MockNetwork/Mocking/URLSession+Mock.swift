import Foundation

extension URLSession {
  /// Returns a `URLSession` that uses the mocked `URLProtocol`.
  convenience init(mock: AnyClass) {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [mock]
    configuration.urlCache = nil
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    self.init(configuration: configuration)
  }
}
