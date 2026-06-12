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
        
        @Presents var myPage: MyPageReducer.State?
        var result: SearchResultReducer.State?
    }
    
    enum Action {
        case inputText(String)
        case clearText
        case onTapMyPage
        case onSubmit
        case myPage(PresentationAction<MyPageReducer.Action>)
        case result(SearchResultReducer.Action)
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
            case .onSubmit:
                state.result = .init()
                return .none
            case .onTapMyPage:
                // myPage 상태에 값을 넣으면(@Presents) MyPage 화면이 "표시됨" 상태가 됨. (nil이면 닫힘)
                state.myPage = .init()
                return .none
            case .result(let resultAction):
                switch resultAction {
                    
                }

            // 자식(MyPage) 화면에서 일어나는 액션이 PresentationAction으로 감싸져 부모(Search)로 전달됨.
            // 즉 Search가 MyPage의 상위 리듀서가 되어, 자식의 액션을 부모에서 가로채 처리할 수 있음.
            case .myPage(let myPagePresentationAction):
                // PresentationAction은 TCA가 제공하는 enum이라 항상 두 케이스를 가짐:
                //  - presented: 자식 화면 내부에서 발생한 자식 리듀서의 액션
                //  - dismiss: 화면이 닫힐 때 발생 (내가 정의한 게 아니라 PresentationAction에 기본 내장된 케이스)
                // 그래서 MyPageReducer.Action에 dismiss가 없어도, 여기선 두 케이스 모두 다뤄야 함.
                switch myPagePresentationAction {
                case let .presented(mypageAction):
                    // 자식 액션을 부모에서 추가로 처리하고 싶을 때 사용 (지금은 처리 없음)
                    return .none
                case .dismiss:
                    // 화면이 닫힐 때 호출됨. 사실 ifLet이 dismiss 시 자동으로 nil 처리해주므로
                    // 아래 줄은 없어도 동작하지만, 명시적으로 닫음을 표현하기 위해 둠.
                    state.myPage = nil
                    return .none
                }
            }
        }
        // ifLet: @Presents로 선언한 옵셔널 자식 상태(myPage)가 "값이 있을 때만" 자식 리듀서를 실행시켜 줌.
        // - 부모 상태(\.$myPage)와 부모 액션(\.myPage)을 자식 리듀서에 연결
        // - myPage가 nil이면 자식 리듀서는 돌지 않고, 값이 생기면 그때부터 MyPageReducer가 동작
        // - dismiss 액션을 받으면 myPage를 자동으로 nil 처리(화면 닫기)까지 해줌
        .ifLet(\.$myPage, action: \.myPage) {
            MyPageReducer()
        }
        .ifLet(\.result, action: \.result) { 
            SearchResultReducer()
        }
    }
}
