import Combine
import ComposableArchitecture
import Core
import Foundation

enum HistoryVM {
    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }

                state.shouldShowHUD = true

                let address = state.address
                return EtherscanClient.publish(
                    ListTransactionRequest(
                        address: address,
                        page: 1,
                        limit: 10000
                    )
                )
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .map { $0.result }
                .catchToEffect()
                .map(HistoryVM.Action.endInitialize)
            case .endInitialize(.success(let transactions)):
                state.transactions = transactions
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .endInitialize(.failure(_)):
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .startRefresh:
                state.shouldPullToRefresh = true

                let address = state.address
                return EtherscanClient.publish(
                    ListTransactionRequest(
                        address: address,
                        page: 1,
                        limit: 10000
                    )
                )
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .map { $0.result }
                .catchToEffect()
                .map(HistoryVM.Action.endRefresh)
            case .endRefresh(.success(let transactions)):
                state.transactions = transactions
                state.shouldPullToRefresh = false
                return .none
            case .endRefresh(.failure(_)):
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
}

extension HistoryVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<[Transaction], AppError>)
        case startRefresh
        case endRefresh(Result<[Transaction], AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var transactions: [Transaction] = []
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
