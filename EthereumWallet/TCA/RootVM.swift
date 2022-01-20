import ComposableArchitecture
import Foundation
import web3swift

enum RootVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .initialize:
            let privateKey = DataStore.shared.getPrivateKey()!
            let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!

            let keystoreManager = KeystoreManager([keystore])
            let pkData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: "web3swift", account: address).toHexString()
            print("secret: \(pkData)")

            state.homeView = HomeVM.State(address: address)
            state.selectTokenView = SelectTokenVM.State(address: address)
            state.historyView = HistoryVM.State(address: address)
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
        case initialize

        case homeView(HomeVM.Action)
        case selectTokenView(SelectTokenVM.Action)
        case historyView(HistoryVM.Action)
    }

    struct State: Equatable {
        var homeView: HomeVM.State?
        var selectTokenView: SelectTokenVM.State?
        var historyView: HistoryVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
