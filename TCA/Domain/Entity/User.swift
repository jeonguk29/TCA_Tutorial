//
//  User.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var name: String
    var email: String
    @Attribute(.externalStorage) var imageData: Data?
    
    init(name: String, email: String, imageData: Data? = nil) {
        self.name = name
        self.email = email
        self.imageData = imageData
    }
}
