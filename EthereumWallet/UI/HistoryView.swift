import ComposableArchitecture
import SwiftUI

struct HistoryView: View {
    let store: Store<HistoryVM.State, HistoryVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEach(viewStore.state.transactions.filter { !$0.isSendToContract() && (Double($0.valueEth) ?? 0.0) > 0.0 }, id: \.self) { transaction in
                    if transaction.isMine(address: viewStore.state.address) {
                        OutHistoryView(transaction: transaction)
                            .listRowSeparator(.hidden)
                    } else {
                        InHistoryView(transaction: transaction)
                            .listRowSeparator(.hidden)
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
            .refreshable {
                await viewStore.send(.startRefresh, while: \.shouldPullToRefresh)
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

            VStack(alignment: .trailing) {
                Text(transaction.displayDate)
                    .foregroundColor(Color.white)
                    .font(.headline)
                Spacer().frame(height: 5)
                VStack(alignment: .leading) {
                    Text(transaction.hash)
                        .lineLimit(nil)
                        .foregroundColor(Color.white)
                        .font(.subheadline)
                    Spacer().frame(height: 10)
                    Text("From: \n\(transaction.from)")
                        .lineLimit(nil)
                        .foregroundColor(Color.white)
                        .font(.subheadline)
                    Spacer().frame(height: 10)
                    Text("Amount: \(transaction.valueEth) Ether")
                        .foregroundColor(Color.white)
                        .font(.headline)
                }
                .padding()
                .background(transaction.error ? Color.red : Color(red: 0, green: 201.0 / 255.0, blue: 167.0 / 255.0))
                .cornerRadius(5.0)
            }
        }
    }
}

struct OutHistoryView: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text(transaction.displayDate)
                    .foregroundColor(Color.white)
                    .font(.headline)
                Spacer().frame(height: 5)
                VStack(alignment: .leading) {
                    Text(transaction.hash)
                        .lineLimit(nil)
                        .foregroundColor(Color.white)
                        .font(.subheadline)
                    Spacer().frame(height: 10)
                    Text("To: \n\(transaction.to)")
                        .lineLimit(nil)
                        .foregroundColor(Color.white)
                        .font(.subheadline)
                    Spacer().frame(height: 10)
                    Text("Amount: \(transaction.valueEth) Ether")
                        .foregroundColor(Color.white)
                        .font(.headline)
                }
                .padding()
                .background(transaction.error ? Color.red : Color(red: 219.0 / 255.0, green: 154.0 / 255.0, blue: 4.0 / 255.0))
                .cornerRadius(5.0)
            }

            Spacer().frame(width: 10)

            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
        }
    }
}
