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
        }
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
                print("keyword: \(keywords.first?.title)")
            }
            .padding(20)
    }
    
    private var contentView: some View {
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
