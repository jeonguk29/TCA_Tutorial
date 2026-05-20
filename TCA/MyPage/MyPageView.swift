//
//  MyPageView.swift
//  TCA
//
//  Created by 정욱 on 5/15/26.
//

import SwiftUI
import ComposableArchitecture
import Alamofire
import SwiftData

// 이름 변경, 이메일 변경, 이미지 변경
enum MyPageOption: CaseIterable {
    case name
    case email
    case image
    
    var title: String {
        switch self {
        case .name:
            "이름"
        case .email:
            "이메일"
        case .image:
            "프로필 이미지"
        }
    }
}

struct MyPageView: View {
    
    // store에 대한 변경 감지, 이렇게 하게 되면 외부에서 주입을 받아야함 
    @Bindable var store: StoreOf<MyPageReducer>
    @Query var users: [User]
    
    var firstUser: User? {
        users.first
    }
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    ForEach(MyPageOption.allCases, id: \.self) { option in
                        let subtitle = switch option {
                        case .name: store.userName
                        case .email: store.userEmail
                        case .image: ""
                        }
                        listItem(option: option, subtitle: subtitle)
                    }
                }
            }
            .onAppear {
                guard let firstUser else { return }
                store.send(.onAppear(firstUser))
            }
        } destination: { store in // 변경이 일어나면 state을 통해서 페이지 이동 및 상태값 주입
            switch store.state {
            case let .name(state):
                // NavigationStackStore 안에 하위 스코프에 접근해서 스코프를 가져와 연결
                if let store = store.scope(state: \.name, action: \.name) {
                    EditNameView(store: store)
                }
            case let .email(state):
                if let store = store.scope(state: \.email, action: \.email) {
                    EditEmailView(store: store)
                }
            case let .image(state):
                if let store = store.scope(state: \.image, action: \.image) {
                    EditImageView(store: store)
                }
            }
        }
    }
    
    func listItem(option: MyPageOption, subtitle: String) -> some View {
        Button {
            //TODO: 버튼 클릭 액션
            store.send(.tapOtion(option))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .bold))
                    Text(subtitle)
                        .foregroundStyle(Color(UIColor.lightGray))
                        .font(.system(size: 16))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(UIColor.darkGray))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
