//
//  KeyWord.swift
//  TCA
//
//  Created by 정욱 on 6/8/26.
//

import SwiftData
import Foundation

@Model
final class Keyword: Identifiable {
    var title: String
    var data: Date
    
    init (title: String, data: Date) {
        self.title = title
        self.data = data
    }
}
