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
}

internal let orderReducer = Reducer<OrderState, OrderAction, Void> { state, action, _ in
    switch action {
    case .didTapMinus:
        state.number -= 1
        state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
        return .none
    case .didTapPlus:
        state.number += 1
        state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
        return .none
    }
}
