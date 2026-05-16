//
//  MyPageReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture

// 엑션과, 스테이트는 리듀서 내부에 위치하면 된다.

@Reducer
struct MyPageReducer {
    
    @ObservableState
    struct State {
        var userName: String = ""
        var userEmail: String = ""
    }
    
    enum Action {
        case onAppear(User)
    }
    
    // 엑션을 받아 상태를 변화 시키고 이팩트를 반환할 순수함수
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // 액션에 대한 처리후 이펙트 반환 해주면 됨, 이 이펙트가 뭘까?
            switch action {
            case let .onAppear(user):
                state.userName = user.name
                state.userEmail = user.email
                return Effect.none
            }
        }
    }
}
