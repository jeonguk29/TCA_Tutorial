//
//  EditEmailReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditEmailReducer {
    struct State {
        var email : String
    }
    enum Action {
        
    }
}

struct EditEmailView: View {
    
    // MARK: - 리듀서 연결
    
    @Bindable var store: StoreOf<EditEmailReducer>
    var body: some View {
        Text("EditEmailView")
    }
}
