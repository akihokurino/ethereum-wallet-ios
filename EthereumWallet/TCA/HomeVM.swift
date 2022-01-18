import Combine
import ComposableArchitecture
import Foundation
import web3swift

enum HomeVM {
    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }

                state.shouldShowHUD = true

                let address = state.address
                let flow = Future<String, Never> { promise in
                    let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                    let balanceWei = try! web3.eth.getBalance(address: address)
                    let balanceEther = Web3.Utils.formatToEthereumUnits(balanceWei, toUnits: .eth, decimals: 3)!
                    promise(.success(balanceEther))
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(HomeVM.Action.endInitialize)
            case .endInitialize(let balance):
                state.balance = balance
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .startRefresh:
                state.shouldPullToRefresh = true

                let address = state.address
                let flow = Future<String, Never> { promise in
                    let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                    let balanceWei = try! web3.eth.getBalance(address: address)
                    let balanceEther = Web3.Utils.formatToEthereumUnits(balanceWei, toUnits: .eth, decimals: 3)!
                    promise(.success(balanceEther))
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(HomeVM.Action.endRefresh)
            case .endRefresh(let balance):
                state.balance = balance
                state.shouldPullToRefresh = false
                return .none
            case .shouldShowHUD(let val):
                state.shouldShowHUD = val
                return .none
            case .shouldPullToRefresh(let val):
                state.shouldPullToRefresh = val
                return .none
            case .startSendTransaction(let payload):
                state.shouldShowHUD = true

                let address = state.address
                let flow = Future<String, Never> { promise in
                    let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                    let toAddress = EthereumAddress(payload.to)!
                    let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
                    let amount = Web3.Utils.parseToBigUInt(payload.to, units: .eth)
                    var options = TransactionOptions.defaultOptions
                    options.value = amount
                    options.from = address
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic

                    let tx = contract.write(
                        "fallback",
                        parameters: [AnyObject](),
                        extraData: Data(),
                        transactionOptions: options
                    )!
                    promise(.success(tx.transaction.txhash ?? ""))
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(HomeVM.Action.endSendTransaction)
            case .endSendTransaction(let txhash):
                print("create tx: \(txhash)")
                state.shouldShowHUD = false
                return .none
            }
        }
    )
}

extension HomeVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(String)
        case startRefresh
        case endRefresh(String)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
        case startSendTransaction(SendTransactionPayload)
        case endSendTransaction(String)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }

    struct SendTransactionPayload: Equatable {
        let to: String
        let value: String
    }
}
