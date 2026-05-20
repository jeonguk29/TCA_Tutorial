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
    
    // MARK: - 스택 네비게이션에 필요한 구성을 한번쯤 생각해봐야함
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
        case tapOtion(MyPageOption)
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
            case let .tapOtion(option): // 2. 스텍을 통한 화면 이동 처리 부분
                switch option {
                case .name:
                    //  state.path 는 MyPageStackReducer state를 말함
                    state.path.append(.name(.init(name: state.userName)))
                case .email:
                    state.path.append(.email(.init(email: state.userEmail)))
                case .image:
                    state.path.append(.image(.init()))
                }
                return Effect.none
            case let .path(stackAction): // 각각 하위 리듀서에서 액션이 일어날때 상위 MyPageStackReducer에서 다 감지가 가능함
                switch stackAction {
                case let .element(id, action):
                    switch action {
                        // 이름 수정후 팝 되면서 변경됨
                    case let .name(.onEditSuccess(name)):
                        state.userName = name
                        state.path.pop(from: id)
                    case let .email(.onEditSuccess(email)):
                        state.userEmail = email
                        state.path.pop(from: id)
                    default: return .none
                    }
                default: return .none
                }
                
                // ⭐️ 엘리먼트 사용하면 하위 리듀서액션을 쉽게 받아올 수 있음
                
                return Effect .none // 부모 리듀서에서 처리할 로직은 여기서 다 하면 된다.
            }
        }// 1. 부모에서 관리하고 있는 모든 내비게이션 스택 스코프를 다 한번에 관리할 수 있도록 함 - 부모 리듀서 셋팅 과정
        .forEach(\.path, action: \.path) {
            MyPageStackReducer()
        }
    }
}
