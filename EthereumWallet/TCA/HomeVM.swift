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
                    let walletAddress = EthereumAddress(address)!
                    let balanceWei = try! web3.eth.getBalance(address: walletAddress)
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
                    let walletAddress = EthereumAddress(address)!
                    let balanceWei = try! web3.eth.getBalance(address: walletAddress)
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
    }

    struct State: Equatable {
        let address: String

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
