//
//  EditNameReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditNameReducer {
    struct State {
        var name: String
    }
    enum Action {
        
    }
}

struct EditNameView: View {
    
    // MARK: - 리듀서 연결
    @Bindable var store: StoreOf<EditNameReducer>
    var body: some View {
        Text("EditNameView")
    }
}
