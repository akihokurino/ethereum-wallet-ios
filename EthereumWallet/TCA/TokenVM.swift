import BigInt
import Combine
import ComposableArchitecture
import Core
import Foundation
import web3swift

enum TokenVM {
    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            guard !state.isInitialized else {
                return .none
            }

            state.shouldShowHUD = true

            let token = state.token
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .high) {
                    do {
                        promise(.success(try await Ethereum.shared.erc20Balance(at: token.address)))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(TokenVM.Action.endInitialize)
        case .endInitialize(.success(let balance)):
            state.balance = balance
            state.isInitialized = true
            state.shouldShowHUD = false
            return .none
        case .endInitialize(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .startRefresh:
            state.shouldPullToRefresh = true

            let token = state.token
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .high) {
                    do {
                        promise(.success(try await Ethereum.shared.erc20Balance(at: token.address)))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(TokenVM.Action.endRefresh)
        case .endRefresh(.success(let balance)):
            state.balance = balance
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
        case .startSendTransaction:
            let amount = state.inputAmount
            let to = state.inputToAddress
            if amount.isEmpty || to.isEmpty {
                return .none
            }
            guard let toAddress = EthereumAddress(to) else {
                return .none
            }

            state.shouldShowHUD = true

            let token = state.token
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .high) {
                    do {
                        promise(.success(try await Ethereum.shared.erc20Transfer(at: token.address, to: toAddress, amount: amount)))
                    } catch {
                        print("send tx error: \(error)")
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(TokenVM.Action.endSendTransaction)
        case .endSendTransaction(.success(let txhash)):
            state.inputAmount = ""
            state.inputToAddress = ""
            state.shouldShowHUD = false
            return .none
        case .endSendTransaction(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .inputAmount(let val):
            state.inputAmount = val
            return .none
        case .inputToAddress(let val):
            state.inputToAddress = val
            return .none
        }
    }
}

extension TokenVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<String, AppError>)
        case startRefresh
        case endRefresh(Result<String, AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
        case startSendTransaction
        case endSendTransaction(Result<String, AppError>)
        case inputAmount(String)
        case inputToAddress(String)
    }

    struct State: Equatable {
        let address: EthereumAddress
        let token: ERC20Token

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""

        var inputAmount = "10"
        var inputToAddress = "0x0E91D6613a84d7C8b72a289D8b275AF7717C3d2E"
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
