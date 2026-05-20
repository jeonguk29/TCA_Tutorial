//
//  EditNameReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI
import SwiftData


@Reducer
struct EditNameReducer {
    
    @ObservableState
    struct State {
        var name: String
        
        // nil이면 사라짐, nil 아니면 뜸 - 트리 기반
        @Presents var alert: AlertState<Action.AlertAction>?
    }
    
    enum Action {
        case inputName(String)
        case clearText
        case onEditFail(String)
        case onEditSuccess(String)
        case showAlert(String)
        case alert(PresentationAction<AlertAction>)
        
        enum AlertAction {
            // alert action 정의해서 사용
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
           
            switch action {
            case let .inputName(name):
                state.name = name
                return .none
            case .clearText:
                state.name = ""
                return .none
            case let .onEditFail(message):
                //TODO: alert
                return .send(.showAlert(message)) // 아래 액션 바로 호출
            case let .showAlert(message):
                // 1. TCA에서 제공해주는 기능 메시지만 제공하면 간단하게 알랏 구현 가능 nil이 아니면 뜨기 때문에 초기화
                state.alert = .init(title: {
                    TextState("에러")
                }, actions: {
                    ButtonState {
                        TextState("확인")
                    }
                }, message: {
                    TextState("에러가 발생했습니다 \(message)")
                })
                return .none
            case .onEditSuccess:
                return .none
            case let .alert(presentationAction):
                // 2. nil이면 알랏 사라지기 때문에 nil로 처리
                switch presentationAction {
                case .dismiss:
                    state.alert = nil
                    return .none
                case let .presented(action):
                    //TODO action 처리
                    return .none
                }
            }
        }
        .ifLet(\.$alert, action: \.alert) // 3. 이게 꼭 필요
    }
}

struct EditNameView: View {
    
    // MARK: - 리듀서 연결
    @Bindable var store: StoreOf<EditNameReducer>
    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    
    private var user: User? {
        users.first
    }
    
    var body: some View {
        VStack{
            Text("이름을 입력해 주세요")
            
            // 바인딩 생성하여면 상태랑, 액션이 정의 되어 있어야함 스토어의 상태,센딩 엑션 순으로 넣어주면 됨 코드 간결해짐
            /*
             TextField에 입력하면 store.name을 직접 바꾸는 게 아니라,
             .inputName(String) Action을 보내고, Reducer에서 state.name을 바꾸는 구조
             */
            TextField("이름을 입력해주세요", text: $store.name.sending(\.inputName))
                .padding(.trailing, 32)
                .overlay(alignment: .topTrailing) {
                    if !store.name.isEmpty {
                        Button {
                            store.send(.clearText)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                }
                .submitLabel(.done) // 키보드 버튼 "완료" 표시
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onSubmit {
                    editName(name: store.name)
                }
        }
        .padding(20)
        .alert($store.scope(state: \.alert, action: \.alert)) // 4. 뷰에다 저장 시키기
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //submit
                    editName(name: store.name)
                } label: {
                    Text("저장 ")
                }
            }
        }
    }
    
    func editName(name: String) {
        guard !name.isEmpty else {
            store.send(.onEditFail("이름을 입력해주세요"))
            return
        }
        
        user?.name = name
        
        do {
            try context.save()
            store.send(.onEditSuccess(name))
        } catch {
            store.send(.onEditFail(error.localizedDescription))
        }
    }
}
