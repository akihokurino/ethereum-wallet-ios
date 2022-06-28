import ComposableArchitecture
import SwiftUI

struct SelectTokenView: View {
    let store: Store<SelectTokenVM.State, SelectTokenVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Group {
                    TextFieldView(value: viewStore.binding(
                        get: \.inputERC20Address,
                        send: SelectTokenVM.Action.inputERC20Address
                    ), label: "ERC20 アドレス", keyboardType: .default)
                    ActionButton(text: "追加", background: .primary) {
                        viewStore.send(.addToken)
                    }
                }
                .listRowSeparator(.hidden)

                Spacer().frame(height: 20)

                ForEach(viewStore.state.tokens, id: \.self) { token in
                    Button(token.name) {
                        viewStore.send(.presentTokenView(token))
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("トークン", displayMode: .inline)
            .onAppear {
                viewStore.send(.initialize)
            }
        }
        .navigate(
            using: store.scope(
                state: \.tokenView,
                action: SelectTokenVM.Action.tokenView
            ),
            destination: TokenView.init(store:),
            onDismiss: {
                ViewStore(store.stateless).send(.popTokenView)
            }
        )
    }
}
