//
//  AlertState + Extension.swift
//  TCA
//
//  Created by 정욱 on 5/24/26.
//

import ComposableArchitecture
import Foundation

enum AlertType {
    case error(message: String)
}

extension AlertState {
    static func createAlert(type: AlertType) -> AlertState {
        switch type {
        case let .error(message):
            return AlertState(title: { TextState("에러")  },
                              actions: {  ButtonState { TextState("확인") } },
                              message: { TextState("에러가 발생했습니다 \(message)") })
        }
    }
}
