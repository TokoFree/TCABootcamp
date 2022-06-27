//
//  OrderVC+Reducer.swift
//  _idx_TCABootcamp_46CB3511_ios_min12.0
//
//  Created by jefferson.setiawan on 16/06/22.
//

import RxComposableArchitecture
import RxSwift

internal struct OrderState: Equatable {
    internal var number: Int
    internal var errorMessage: String?
    internal var isMinusButtonEnabled: Bool { number > 0 }
}

internal enum OrderAction: Equatable {
    case didTapMinus
    case didTapPlus
    case textDidChange(String)
}

internal let orderReducer = Reducer<OrderState, OrderAction, Void> { state, action, _ in
    func validateNumber() {
        state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
    }
    switch action {
    case .didTapMinus:
        state.number -= 1
        validateNumber()
        return .none
    case .didTapPlus:
        state.number += 1
        validateNumber()
        return .none
    case let .textDidChange(string):
        if let number = Int(string) {
            state.number = number
            validateNumber()
            return .none
        } else {
            state.number = 0
            state.errorMessage = "Should only contains numeric"
            return .none
        }
    }
}
