import Combine
import ComposableArchitecture
import Foundation
import web3swift

enum RootVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            state.shouldShowHUD = true

            let flow = Future<EthereumAddress, AppError> { promise in
                DispatchQueue.global(qos: .background).async {
                    do {
                        let privateKey = DataStore.shared.getPrivateKey()!
                        let keystore = try EthereumKeystoreV3(privateKey: privateKey)!
                        promise(.success(keystore.addresses!.first!))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(RootVM.Action.endInitialize)
        case .endInitialize(.success(let address)):
            state.homeView = HomeVM.State(address: address)
            state.selectTokenView = SelectTokenVM.State(address: address)
            state.historyView = HistoryVM.State(address: address)
            state.shouldShowHUD = false
            return .none
        case .endInitialize(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .shouldShowHUD(let val):
            state.shouldShowHUD = val
            return .none
        case .homeView(let action):
            return .none
        case .selectTokenView(let action):
            return .none
        case .historyView(let action):
            return .none
        }
    }
    .connect(
        HomeVM.reducer,
        state: \.homeView,
        action: /RootVM.Action.homeView,
        environment: { _environment in
            HomeVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
    .connect(
        SelectTokenVM.reducer,
        state: \.selectTokenView,
        action: /RootVM.Action.selectTokenView,
        environment: { _environment in
            SelectTokenVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
    .connect(
        HistoryVM.reducer,
        state: \.historyView,
        action: /RootVM.Action.historyView,
        environment: { _environment in
            HistoryVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
}

extension RootVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<EthereumAddress, AppError>)
        case shouldShowHUD(Bool)

        case homeView(HomeVM.Action)
        case selectTokenView(SelectTokenVM.Action)
        case historyView(HistoryVM.Action)
    }

    struct State: Equatable {
        var shouldShowHUD = false
        var homeView: HomeVM.State?
        var selectTokenView: SelectTokenVM.State?
        var historyView: HistoryVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
