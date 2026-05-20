//
//  EditEmailReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI
import SwiftData

@Reducer
struct EditEmailReducer {
    
    @ObservableState
    struct State {
        var email : String

        @Presents var alert: AlertState<Action.AlertAction>?
    }
    
    enum Action {
        case inputEamil(String)
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
            case let .inputEamil(name):
                state.email = name
                return .none
            case .clearText:
                state.email = ""
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
        .ifLet(\.$alert, action: \.alert) // 3. 이게 사실상 “Reducer야, alert라는 Optional State가 존재할 때 그 Alert에서 발생하는 Action도 처리할 수 있게 연결한것
        
    }
}

struct EditEmailView: View {
    
    // MARK: - 리듀서 연결
    
    @Bindable var store: StoreOf<EditEmailReducer>
    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    
    private var user: User? {
        users.first
    }
    
    var body: some View {
        VStack{
            Text("이메일을 입력해 주세요")
            
            TextField("이메일을 입력해주세요", text: $store.email.sending(\.inputEamil))
                .padding(.trailing, 32)
                .overlay(alignment: .topTrailing) {
                    if !store.email.isEmpty {
                        Button {
                            store.send(.clearText)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                }
                .submitLabel(.done)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onSubmit {
                    EditEmail(email: store.email)
                }
        }
        .padding(20)
        .alert($store.scope(state: \.alert, action: \.alert))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //submit
                    EditEmail(email: store.email)
                } label: {
                    Text("저장")
                }
            }
        }
    }
    
    func EditEmail(email: String) {
        guard !email.isEmpty else {
            store.send(.onEditFail("이메일을 입력해주세요"))
            return
        }
        
        user?.email = email
        
        do {
            try context.save()
            store.send(.onEditSuccess(email))
        } catch {
            store.send(.onEditFail(error.localizedDescription))
        }
    }
}

