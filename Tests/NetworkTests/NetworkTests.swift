import XCTest
@testable import Network

extension URLSession {
  /// Returns a `URLSession` that uses the mocked `URLProtocol`.
  static var mock: URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    MockURLProtocol.delay = 2
    configuration.urlCache = nil
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    return URLSession(configuration: configuration)
  }
}

final class NetworkTests: XCTestCase {

  let session = URLSession.mock

  private struct DemoResponse: Decodable, Equatable {
    let text: String
  }

  private struct DemoGetRequest: DecodableRequest {
    typealias ResponseModel = DemoResponse

    let authorizationType: AuthorizationType = .none
    let method: HTTPMethod = .get
    let host = "example.com"
    var path: URL.Path = []
  }

  func test_request_correctly_parsesAndReturnsModel() async throws {
    let testUrl = URL(string: "https://example.com/test_request_correctly_parsesAndReturnsModel")!

    let networkExchange = NetworkExchange(
      urlRequest: URLRequest(url: testUrl),
      response: ServerResponse(
        statusCode: .code200,
        data: "{\"text\": \"Some data\"}".data(using: .utf8)
      )
    )

    MockURLProtocol.mockRequests.insert(networkExchange)

    let expectedResponse = DemoResponse(text: "Some data")
    let request = DemoGetRequest(path: ["test_request_correctly_parsesAndReturnsModel"])
    let networkManager = NetworkManager(using: session)
    let actualResponse = try await networkManager.request(request)
    XCTAssertEqual(actualResponse, expectedResponse)
  }

  func test_request_catches_serverError() async {
    let testUrl = URL(string: "https://example.com/test_request_catches_serverError")!

    let networkExchange = NetworkExchange(
      urlRequest: URLRequest(url: testUrl),
      response: ServerResponse(statusCode: .code500)
    )

    MockURLProtocol.mockRequests.insert(networkExchange)

    let networkManager = NetworkManager(using: session)
    let expectation = XCTestExpectation()

    do {
      _ = try await networkManager.request(DemoGetRequest(path: ["test_request_catches_serverError"]))
    } catch {
      XCTAssertEqual(error as? NetworkError, .serverError(500))
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }

  func test_request_catches_requestTimedOutConnectionError() async {
    let testUrl = URL(string: "https://example.com/test_request_catches_requestTimedOutConnectionError")!

    let networkExchange = NetworkExchange(
      urlRequest: URLRequest(url: testUrl),
      response: nil,
      error: .requestTimedOut
    )

    MockURLProtocol.mockRequests.insert(networkExchange)

    let networkManager = NetworkManager(using: session)

    let expectation = XCTestExpectation()

    do {
      _ = try await networkManager.request(DemoGetRequest(path: ["test_request_catches_requestTimedOutConnectionError"]))
    } catch {
      XCTAssertEqual(error as? NetworkError, .requestTimedOut)
      expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 5)
  }
}
