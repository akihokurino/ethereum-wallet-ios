import ComposableArchitecture
import SwiftUI

struct SelectTokenView: View {
    let store: Store<SelectTokenVM.State, SelectTokenVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Button("CustomToken") {
                    viewStore.send(.presentCustomTokenView)
                }
            }
            .navigationBarTitle("トークン", displayMode: .inline)
        }
        .navigate(
            using: store.scope(
                state: \.customTokenView,
                action: SelectTokenVM.Action.customTokenView
            ),
            destination: CustomTokenView.init(store:),
            onDismiss: {
                ViewStore(store.stateless).send(.popCustomTokenView)
            }
        )
    }
}
