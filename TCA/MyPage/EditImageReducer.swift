//
//  EditImageReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditImageReducer {
    struct State {
        
    }
    enum Action {
        
    }
}

struct EditImageView: View {
    
    // MARK: - 리듀서 연결
    
    @Bindable var store: StoreOf<EditImageReducer>
    var body: some View {
        Text("EditImageView")
    }
}
