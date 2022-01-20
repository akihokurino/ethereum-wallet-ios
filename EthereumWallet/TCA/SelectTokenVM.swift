import ComposableArchitecture
import Foundation
import web3swift

enum SelectTokenVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .presentCustomTokenView:
            state.customTokenView = CustomTokenVM.State(address: state.address)
            return .none
        case .popCustomTokenView:
            state.customTokenView = nil
            return .none
        case .customTokenView(let action):
            return .none
        }
    }
    .connect(
        CustomTokenVM.reducer,
        state: \.customTokenView,
        action: /SelectTokenVM.Action.customTokenView,
        environment: { _environment in
            CustomTokenVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
}

extension SelectTokenVM {
    enum Action: Equatable {
        case presentCustomTokenView
        case popCustomTokenView

        case customTokenView(CustomTokenVM.Action)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var customTokenView: CustomTokenVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
