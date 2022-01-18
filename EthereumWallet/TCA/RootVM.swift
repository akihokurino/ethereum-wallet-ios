import ComposableArchitecture
import Foundation
import web3swift

enum RootVM {
    static let reducer = Reducer<State, Action, Environment>.combine(
        HomeVM.reducer.optional().pullback(
            state: \RootVM.State.homeView,
            action: /RootVM.Action.homeView,
            environment: { _environment in
                HomeVM.Environment(mainQueue: _environment.mainQueue, backgroundQueue: _environment.backgroundQueue)
            }
        ),
        HistoryVM.reducer.optional().pullback(
            state: \RootVM.State.historyView,
            action: /RootVM.Action.historyView,
            environment: { _environment in
                HistoryVM.Environment(mainQueue: _environment.mainQueue, backgroundQueue: _environment.backgroundQueue)
            }
        ),
        Reducer { state, action, _ in
            switch action {
            case .initialize:
                let privateKey = DataStore.shared.getPrivateKey()!
                let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                let address = keystore.addresses!.first!.address
                state.homeView = HomeVM.State(address: address)
                state.historyView = HistoryVM.State(address: address)
                return .none
            case .homeView(let action):
                return .none
            case .historyView(let action):
                return .none
            }
        }
    )
}

extension RootVM {
    enum Action: Equatable {
        case initialize

        case homeView(HomeVM.Action)
        case historyView(HistoryVM.Action)
    }

    struct State: Equatable {
        var homeView: HomeVM.State?
        var historyView: HistoryVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
