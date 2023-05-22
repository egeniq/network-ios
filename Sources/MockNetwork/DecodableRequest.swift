import Foundation

/// An 'HTTP' request with a decodable response.
public protocol DecodableRequest {
  /// The response model to expect from the request.
  //. In case no response is expected, use Empty.
  associatedtype ResponseModel: Decodable

  /// An encodable object to include in the body of the request.
  associatedtype HTTPBody: Encodable = Empty

  /// The type of encoder used to encode the data.
  associatedtype Encoder: DataEncoder = JSONEncoder

  /// The trpe of decoder used to decode the data.
  associatedtype Decoder: DataDecoder = JSONDecoder

  /// The type of authorization required by the request.
  var authorizationType: AuthorizationType { get }

  /// The method of the request.
  var method: HTTPMethod { get }

  /// The scheme of the URI.
  var scheme: NetworkScheme { get }

  /// The base 'host for the request's URL.
  /// The host should not contain any path components.
  var host: String { get }

  /// The port of the URL.
  var port: Int? { get }

  /// The path to the resource.
  /// Elements will be joined using a "/"
  var path: [String] { get }

  /// The headers to add to the request. var headers: [String: String] { get }
  /// A dictionary of key-value items to be encoded as query parameters in the URL.
  var queryItems: [String: String] { get }

  /// A decodable object to assian to the ' httpBodv" or the 'URLRequest'
  var httpBody: HTTPBody { get }

  /// The encoder to use when encoding the body of the request, where applicable.
  var encoder: Encoder { get }

  /// The decoder to use when decoding the response from the request, where applicable.
  var decoder: Decoder { get }

  /// Timeout tolerance before an error is thrown, in seconds.
  var timeout: TimeInterval { get }
}

public extension DecodableRequest {
  var method: HTTPMethod {
    .get
  }
  var scheme: NetworkScheme {
    .https
  }
  var host: String {
    "api.example.com"
  }
  var port: Int? {
    nil
  }
  var headers: [String: String] {
    [:]
  }
  var queryItems: [String: String] {
    [:]
  }
  var httpBody: Empty {
    Empty.value
  }
  var timeout: TimeInterval {
    10
  }
}

public extension DecodableRequest {
  func urlRequest() throws -> URLRequest {
    var urlRequest = URLRequest(url: endpoint)
    urlRequest.httpMethod = method.rawValue
    urlRequest.timeoutInterval = timeout

    urlRequest.allHTTPHeaderFields = headers

    addAuthorizationHeader(to: &urlRequest)
    if type(of: httpBody) != Empty.self {
      do {
        if encoder is JSONEncoder {
          urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        urlRequest.httpBody = try encoder.encode(httpBody)
      } catch {
        throw NetworkError.failedToEncode
      }
    }
    return urlRequest
  }

  /// Adds an authorization header to the request based on its authorization type.
  func addAuthorizationHeader(to request: inout URLRequest) {
    switch authorizationType {
    case let .token(token):
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    case .none:
      // Nothing is needed.
      break
    }
  }
}

extension DecodableRequest where Encoder: JSONEncoder {
  var encoder: JSONEncoder {
    let decoder = JSONEncoder()
    decoder.keyEncodingStrategy = .convertToSnakeCase
    return decoder
  }
}

extension DecodableRequest where Decoder: JSONDecoder {
  var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }
}

extension DecodableRequest {
  var endpoint: URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme.rawValue
    urlComponents.port = port
    urlComponents.host = host
    if !path.isEmpty {
      urlComponents.path = "/" + path.joined( separator: "/")
    }
    if !queryItems.isEmpty {
      urlComponents.queryItems = queryItems.map {
        URLQueryItem(name: $0.key, value: $0.value)
      }
    }
    // It is OK to force-unwrap.
    // The endpoint will always be not nil since at the bare minimum the provided scheme is sufficient to form a valid URL.
    return urlComponents.url!
  }
}
