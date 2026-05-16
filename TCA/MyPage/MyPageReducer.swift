//
//  MyPageReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture

@Reducer
struct MyPageStackReducer {
    @ObservableState
    
    enum State {
        case name(EditNameReducer.State) // 이름 변경 페이지 리듀서 상태
        case email(EditEmailReducer.State) // 이메일 변경 페이지 리듀서 상태
        case image(EditImageReducer.State) // 이미지 변경 페이지 리듀서 상태
    }
    
    enum Action {
        case name(EditNameReducer.Action) // 이름 변경 페이지 리듀서 액션
        case email(EditEmailReducer.Action) // 이메일 변경 페이지 리듀서 액션
        case image(EditImageReducer.Action) // 이미지 변경 페이지 리듀서 액션
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.name, action: \.name) {
            EditNameReducer()
        }
        Scope(state: \.email, action: \.email) {
            EditEmailReducer()
        }
        Scope(state: \.image, action: \.image) {
            EditImageReducer()
        }
    }
}


// 엑션과, 스테이트는 리듀서 내부에 위치하면 된다.

@Reducer
struct MyPageReducer {
    
    @ObservableState
    struct State {
        var path: StackState<MyPageStackReducer.State> = .init()
        var userName: String = ""
        var userEmail: String = ""
    }
    
    enum Action {
        case onAppear(User)
        case path(StackActionOf<MyPageStackReducer>)
    }
    
    // 엑션을 받아 상태를 변화 시키고 이팩트를 반환할 순수함수
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // 액션에 대한 처리후 이펙트 반환 해주면 됨
            switch action {
            case let .onAppear(user):
                state.userName = user.name
                state.userEmail = user.email
                return Effect.none
            case let .path(stackAction): // 각각 하위 리듀서에서 액션이 일어날때 상위 MyPageStackReducer에서 다 감지가 가능함
                return .none // 부모 리듀서에서 처리할 로직은 여기서 다 하면 된다.
            }
        }// 부모에서 관리하고 있는 모든 내비게이션 스택 스코프를 다 한번에 관리할 수 있도록 함
        .forEach(\.path, action: \.path) {
            MyPageStackReducer()
        }
    }
}
