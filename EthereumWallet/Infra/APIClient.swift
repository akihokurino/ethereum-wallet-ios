import Alamofire
import Foundation
import SwiftUI
import Combine

protocol BaseAPIProtocol {
    associatedtype ResponseType

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var allowsConstrainedNetworkAccess: Bool { get }
}

extension BaseAPIProtocol {
    var baseURL: URL {
        return URL(string: Env["ETHERSCAN_API_URL"]!)!
    }

    var headers: [String: String]? {
        return nil
    }

    var allowsConstrainedNetworkAccess: Bool {
        return true
    }
}

protocol BaseRequestProtocol: BaseAPIProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: URLEncoding { get }
}

extension BaseRequestProtocol {
    var encoding: URLEncoding {
        return URLEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.timeoutInterval = TimeInterval(30)
        urlRequest.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess

        if let params = parameters {
            urlRequest = try encoding.encode(urlRequest, with: params)
        }

        return urlRequest
    }
}

struct NetworkPublisher {
    private static let successRange = 200 ..< 300
    private static let contentType = "application/json"
    private static let retryCount: Int = 1
    static let decorder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()

    static func publish<T, V>(_ request: T) -> Future<V, AppError>
        where T: BaseRequestProtocol, V: Codable, T.ResponseType == V
    {
        return Future { promise in
            let api = AF.request(request)
                .validate(statusCode: self.successRange)
                .validate(contentType: [self.contentType])
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        do {
                            if let data = response.data {
                                let result = try self.decorder.decode(V.self, from: data)
                                promise(.success(result))
                            } else {
                                promise(.failure(AppError.defaultError()))
                            }

                        } catch {
                            promise(.failure(AppError.defaultError()))
                        }
                    case let .failure(error):
                        promise(.failure(AppError.plain(error.errorDescription ?? "エラーが発生しました")))
                    }
                }
            api.resume()
        }
    }
}
