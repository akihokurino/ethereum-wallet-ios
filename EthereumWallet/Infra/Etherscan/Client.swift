import Alamofire
import Combine
import Foundation
import SwiftUI

protocol EtherscanAPIProtocol {
    associatedtype ResponseType

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var allowsConstrainedNetworkAccess: Bool { get }
}

extension EtherscanAPIProtocol {
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

protocol EtherscanRequestProtocol: EtherscanAPIProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: URLEncoding { get }
}

extension EtherscanRequestProtocol {
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
        
        print(urlRequest.url!)
    
        return urlRequest
    }
}

struct EtherscanClient {
    private static let successRange = 200 ..< 300
    private static let contentType = "application/json"
    private static let retryCount: Int = 1
    static let decorder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()

    static func publish<T, V>(_ request: T) -> Future<V, AppError>
        where T: EtherscanRequestProtocol, V: Codable, T.ResponseType == V
    {
        return Future { promise in
            let api = AF.request(request)
                .validate(statusCode: self.successRange)
                .validate(contentType: [self.contentType])
                .responseDecodable(of: V.self) { response in
                    switch response.result {
                    case let .success(result):
                        promise(.success(result))
                    case let .failure(error):
                        promise(.failure(AppError.plain(error.errorDescription ?? "エラーが発生しました")))
                    }
                }
            api.resume()
        }
    }
}
