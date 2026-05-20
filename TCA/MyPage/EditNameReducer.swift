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
    
    @ObservableState
    struct State {
        var name: String
    }
    enum Action {
        case inputName(String)
        case clearText
    }
}

struct EditNameView: View {
    
    // MARK: - 리듀서 연결
    @Bindable var store: StoreOf<EditNameReducer>
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
                    
                }
        }
        .padding(20)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //submit
                } label: {
                    Text("저장 ")
                }
            }
        }
    }
}
