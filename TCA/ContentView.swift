//
//  ContentView.swift
//  TCA
//
//  Created by 정욱 on 5/15/26.
//

import SwiftUI
import ComposableArchitecture
import Alamofire

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
