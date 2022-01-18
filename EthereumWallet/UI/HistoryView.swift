import ComposableArchitecture
import SwiftUI

struct HistoryView: View {
    let store: Store<HistoryVM.State, HistoryVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEach(viewStore.state.transactions, id: \.self) { transaction in
                    if transaction.from == viewStore.state.address.address {
                        OutHistoryView(transaction: transaction)
                    } else {
                        InHistoryView(transaction: transaction)
                    }
                }
                
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("履歴", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: HistoryVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
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

struct InHistoryView: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .bottom) {
            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)

            Spacer().frame(width: 10)

            VStack(alignment: .leading) {
                Text("トランザクションハッシュ: \n\(transaction.hash)")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("送り元: \n\(transaction.from)")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("総額: \(transaction.valueEth) Ether")
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("日付: \(transaction.displayDate)")
                    .foregroundColor(Color.white)
            }
            .padding()
            .background(Color(red: 0, green: 201.0 / 255.0, blue: 167.0 / 255.0))
            .cornerRadius(5.0)
        }
    }
}

struct OutHistoryView: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("トランザクションハッシュ: \n\(transaction.hash)")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("送り先: \n\(transaction.to)")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("総額: \(transaction.valueEth) Ether")
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("日付: \(transaction.displayDate)")
                    .foregroundColor(Color.white)
            }
            .padding()
            .background(Color(red: 219.0 / 255.0, green: 154.0 / 255.0, blue: 4.0 / 255.0))
            .cornerRadius(5.0)

            Spacer().frame(width: 10)

            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
        }
    }
}
