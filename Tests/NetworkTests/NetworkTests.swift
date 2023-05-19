import XCTest
@testable import Network

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

final class NetworkTests: XCTestCase {

  let testUrl = URL(string: "https://example.com/path/to/resource")!

  private struct DemoResponse: Decodable, Equatable {
    let text: String
  }

  private struct DemoGetRequest: DecodableRequest {
    typealias ResponseModel = DemoResponse

    let authorizationType: AuthorizationType = .none
    let method: HTTPMethod = .get
    let host = "example.com"
    var path: URL.Path = ["path", "to", "resource"]
  }

  func test_request_correctly_parsesAndReturnsModel() async throws {
    let networkExchange = NetworkExchange(
      urlRequest: URLRequest(url: testUrl),
      response: ServerResponse(
        statusCode: .code200,
        data: "{\"text\": \"Some data\"}".data(using: .utf8)
      )
    )

    class Mock: MockURLProtocol { }
    let session = URLSession(mock: Mock.self)
    Mock.mockRequests = { [networkExchange] }

    let expectedResponse = DemoResponse(text: "Some data")
    let request = DemoGetRequest()
    let networkManager = NetworkManager(using: session)
    let actualResponse = try await networkManager.request(request)
    XCTAssertEqual(actualResponse, expectedResponse)
  }

  func test_request_catches_serverError() async {
    let networkExchange = NetworkExchange(
      urlRequest: URLRequest(url: testUrl),
      response: ServerResponse(statusCode: .code500)
    )

    class Mock: MockURLProtocol { }
    let session = URLSession(mock: Mock.self)
    Mock.mockRequests = { [networkExchange] }

    let networkManager = NetworkManager(using: session)
    let expectation = XCTestExpectation()

    do {
      _ = try await networkManager.request(DemoGetRequest())
    } catch {
      XCTAssertEqual(error as? NetworkError, .serverError(500))
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }

  func test_request_catches_requestTimedOutConnectionError() async {
    let networkExchange = NetworkExchange(
      urlRequest: URLRequest(url: testUrl),
      response: nil,
      error: .requestTimedOut
    )

    class Mock: MockURLProtocol { }
    let session = URLSession(mock: Mock.self)
    Mock.mockRequests = { [networkExchange] }

    let networkManager = NetworkManager(using: session)

    let expectation = XCTestExpectation()

    do {
      _ = try await networkManager.request(DemoGetRequest())
    } catch {
      XCTAssertEqual(error as? NetworkError, .requestTimedOut)
      expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 5)
  }
}
