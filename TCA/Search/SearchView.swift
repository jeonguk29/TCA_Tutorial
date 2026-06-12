//
//  SearchView.swift
//  TCA
//
//  Created by 정욱 on 6/8/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import Foundation
 
struct SearchView: View {
    
    @Bindable var store : StoreOf<SearchReducer>
    @Environment(\.modelContext) private var context
    @Query(sort: \Keyword.date, order: .reverse) private var keywords: [Keyword]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    textField
                    contentView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("검색")
                        .font(.title)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.onTapMyPage)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        // SwiftUI 기본 .sheet(item:)은 item이 옵셔널 Identifiable일 때, 값이 있으면 시트를 띄우고 nil이면 닫음.
        // 여기서는 그 item 자리에 store.scope(...)를 넘겨 "자식 화면 전용 스토어"를 만들어 주입함.
        //  - state: \.myPage  -> 부모 상태 중 myPage(옵셔널) 부분을 자식 상태로 떼어냄
        //  - action: \.myPage -> 자식에서 발생한 액션을 부모의 .myPage 액션으로 다시 감싸 전달
        // 즉 myPage 상태가 nil→값으로 바뀌면 시트가 뜨고($store.scope가 자식 StoreOf<MyPageReducer>를 만들어줌),
        // 닫히면 dismiss가 부모로 전달되어 myPage가 nil이 되며 시트가 사라짐.
        .sheet(
            item: $store.scope(
                state: \.myPage,
                action: \.myPage
            )
        ) { store in
            MyPageView(store: store)
        }

    // .fullScreenCover도 사용법은 동일. 시트 대신 전체 화면으로 띄우고 싶을 때 위 .sheet 대신 쓰면 됨.
    //    .fullScreenCover(
    //        item: $store.scope(
    //            state: \.myPage,
    //            action: \.myPage
    //        )
    //    ) { store in
    //        MyPageView(store: store)
    //    }
    }
    
    private var textField: some View {
        TextField("키워드를 검색해보세요", text: $store.keyword.sending(\.inputText))
            .frame(height: 40)
            .font(.system(size: 15))
            .padding(.trailing, 32)
            .padding(.leading, 12)
            .padding(.vertical, 8)
            .focused($isFocused)
            .overlay(alignment: .trailing) {
                Button {
                    store.send(.clearText)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal, 20)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            }
            .onSubmit {
                // 키워드 저장
                // 검색
                saveKeyword(keyword: store.keyword)
                store.send(.onSubmit)
            }
            .padding(20)
    }
    
    private var contentView: some View {
        
        // 분기
        Group {
            // 스토어가 생기면 해당 코드 블럭을 탐
            if let store = store.scope(state: \.result, action: \.result) {
                // 2. 검색 결과 리스트
                SearchResultView()
            } else {
                // 1. 키워드 리스트
                keywordList
            }
        }
    }
    
    var keywordList: some View {
        ForEach(keywords, id: \.id) { keyword in
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                    
                    Text(keyword.title)
                        .font(.system(size: 16))
                        .padding(.leading, 10)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .onTapGesture {
                    // TODO: 검색
                }
                
                Button {
                    // TODO delete keyword
                    deleteKeyword(keyword: keyword)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                }
            }
            .padding(20)
        }
    }
    
    func saveKeyword(keyword: String) {
        let data = Keyword(title: keyword, data: Date.now)
        context.insert(data)
        try? context.save()
    }
    
    func deleteKeyword(keyword: Keyword) {
//        let descriptor = FetchDescriptor<Keyword>(predicate: #Predicate { $0.title == keyword })
//        if let model = try? context.fetch(descriptor).first {
//            context.delete(model)
//        }
        
        context.delete(keyword)
        try? context.save()
    }
}
