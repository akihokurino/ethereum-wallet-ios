import SwiftUI
import ComposableArchitecture

struct CustomTokenView: View {
    let store: Store<CustomTokenVM.State, CustomTokenVM.Action>
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
