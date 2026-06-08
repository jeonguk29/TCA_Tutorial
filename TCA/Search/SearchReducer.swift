//
//  SearchReducer.swift
//  TCA
//
//  Created by 정욱 on 6/8/26.
//

import ComposableArchitecture

@Reducer
struct SearchReducer {
    
    @ObservableState
    struct State {
        var keyword: String = ""
    }
    
    enum Action {
        case inputText(String)
        case clearText
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            
            switch action {
            case .inputText(let text):
                state.keyword = text
                return .none
            case .clearText:
                state.keyword = ""
                return .none
            }
        }
    }
}
