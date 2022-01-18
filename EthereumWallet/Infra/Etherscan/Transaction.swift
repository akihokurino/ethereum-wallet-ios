import Alamofire
import Foundation
import web3swift
import BigInt

class ListTransactionRequest: EtherscanRequestProtocol {
    typealias ResponseType = TransactionList
    
    let address: EthereumAddress
    let page: Int
    let limit: Int
    
    init(address: EthereumAddress, page: Int, limit: Int) {
        self.address = address
        self.page = page
        self.limit = limit
    }
    
    var parameters: Parameters? {
        return [
            "module": "account",
            "action": "txlist",
            "address": address.address,
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

struct Transaction: Codable, Identifiable, Equatable, Hashable {
    let blockNumber: String
    let blockHash: String
    let timeStamp: String
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
    
    var valueEth: String {
        return Web3.Utils.formatToEthereumUnits(BigUInt(UInt(value) ?? 0), toUnits: .eth, decimals: 3)!
    }
    
    var displayDate: String {
        guard let t = Double(timeStamp) else {
            return ""
        }
        
        let date = Date(timeIntervalSince1970: t)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
