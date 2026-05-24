//
//  EditImageReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI
import Photos
import SwiftData

@Reducer
struct EditImageReducer {
    
    @ObservableState
    struct State {
        @Presents var alert: AlertState<Action>?
    }
    enum Action {
        case onAppear
        case authResult(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action  {
            case .onAppear:
                // 비동기 함수 사용할때는 Effect.run 라는 Effect 사용을 해야함
                // Reducer는 항상 액션을 받으면 Effect를 리턴해야함
                return Effect.run { send in
                    let isAuth = await PhotoManager.requestAuthorization()
                    await send(.authResult(isAuth))
                }
            case let .authResult(isAuth):
                if isAuth { // 권한 하용이면 이미지 가져오기
                    let assets = PhotoManager.getAssets()
                } else {
                    state.alert = AlertState.createAlert(type: .error(message: "권한이 없습니다"))
                }
                return .none
            }
            
            return .none
        }
    }
}

struct EditImageView: View {
    @Bindable var store: StoreOf<EditImageReducer>

    var body: some View {
       Text("EditImageView")
            .onAppear {
                store.send(.onAppear)
            }
    }
}
