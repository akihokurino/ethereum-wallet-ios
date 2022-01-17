import Alamofire
import Foundation

class ListTransactionRequest: BaseRequestProtocol {
    typealias ResponseType = TransactionList
    
    let address: String
    let page: Int
    let limit: Int
    
    init(address: String, page: Int, limit: Int) {
        self.address = address
        self.page = page
        self.limit = limit
    }
    
    var parameters: Parameters? {
        return [
            "module": "account",
            "action": "txlist",
            "address": address,
            "startblock": 0,
            "endblock": 99999999,
            "page": page,
            "offset": limit,
            "sort": "desc",
            "apikey": Env["ETHERSCAN_API_KEY"]!
        ]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "api"
    }

    var allowsConstrainedNetworkAccess: Bool {
        return false
    }
}

struct TransactionList: Codable, Equatable {
    let result: [Transaction]
}

struct Transaction: Codable, Identifiable, Equatable {
    let blockNumber: String
    let blockHash: String
    let timestamp: String?
    let hash: String
    let from: String
    let to: String
    let value: String
    let gas: String
    let gasPrice: String
    let gasUsed: String

    var id: String {
        return hash
    }
}
