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
    @Query private var keyword: [Keyword]
    @FocusState private var isFocused: Bool 
    
    var body: some View {
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
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            }
            .onSubmit {
                // 키워드 저장
                // 검색
                saveKeyword(keyword: store.keyword)
                print("keyword: \(keyword.first?.title)")
            }
    }
    
    func saveKeyword(keyword: String) {
        let data = Keyword(title: keyword, data: Date.now)
        context.insert(data)
        try? context.save()
    }
}
