import ComposableArchitecture
import SwiftUI

struct HistoryView: View {
    let store: Store<HistoryVM.State, HistoryVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Text("Item 1")
                    .listRowSeparator(.hidden)
                Text("Item 2")
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("履歴", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                HUD(isLoading: viewStore.binding(
                    get: \.shouldShowHUD,
                    send: HistoryVM.Action.shouldShowHUD
                )), alignment: .center
            )
            .pullToRefresh(isShowing: viewStore.binding(
                get: \.shouldPullToRefresh,
                send: HistoryVM.Action.shouldPullToRefresh
            )) {
                viewStore.send(.startRefresh)
            }
        }
    }
}
