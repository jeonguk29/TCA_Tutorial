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
enum MyPagePath: CaseIterable {
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
       
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                ForEach(MyPagePath.allCases, id: \.self) { option in
                    listItem(option: option)
                }
            }
        }
        .onAppear {
            guard let firstUser else { return }
            store.send(.onAppear(firstUser))
        }
    }
    
    func listItem(option: MyPagePath) -> some View {
        Button {
            //TODO: 버튼 클릭 액션
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .bold))
                    Text(firstUser?.name ?? "")
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
