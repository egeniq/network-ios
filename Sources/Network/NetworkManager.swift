import Foundation

public struct NetworkManager {
  /// The instance of `URLSession` to use when making data requests.
  internal let session: URLSession

  /// Creates and returns a configured instance of `NetworkManager`.
  public init(using session: URLSession) {
    self.session = session
  }

  public func request<R: DecodableRequest>(_ request: R) async throws -> R.ResponseModel {
    let data: Data
    let response: URLResponse
    let responseModel: R.ResponseModel

    do {
      let urlRequest = try request.urlRequest()
      if #available(macOS 12.0, iOS 15.0, *) {
          (data, response) = try await session.data(for: urlRequest)
      } else {
        // Fallback on earlier versions
        (data, response) = try await withCheckedThrowingContinuation { continuation in
          session.dataTask(with: urlRequest) { data, response, error in
            if let error  {
              continuation.resume(throwing: error)
            } else if let data, let response {
              continuation.resume(returning: (data, response))
            } else {
              continuation.resume(throwing: NSError(domain: "NetworkManager", code: 1))
            }
          }
        }
      }
    } catch {
      guard let err = error as? URLError else {
        throw NetworkError.generic(error)
      }
      if err.code.rawValue == NSURLErrorNotConnectedToInternet {
        throw NetworkError.noInternetConnection
      }
      if err.code.rawValue == NSURLErrorTimedOut {
        throw NetworkError.requestTimedOut
      }
      throw NetworkError.generic(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.serverResponseNotValid
    }

    if httpResponse.statusCode.between(400, and: 499) {
      if httpResponse.statusCode == 403 {
        throw NetworkError.forbidden
      }

      if httpResponse.statusCode == 404 {
        throw NetworkError.resourceNotFound
      }

      throw NetworkError.clientError(httpResponse.statusCode)
    }

    if httpResponse.statusCode.between(500, and: 599) {
      throw NetworkError.serverError(httpResponse.statusCode)
    }

    do {
      responseModel = try request.decoder.decode(R.ResponseModel.self, from: data)
    } catch {
      throw NetworkError.failedToDecode(data)
    }
    return responseModel
  }
}
