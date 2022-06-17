//
//  CounterVC+Reducer.swift
//  _idx_TCABootcamp_46CB3511_ios_min12.0
//
//  Created by jefferson.setiawan on 16/06/22.
//

import RxComposableArchitecture

internal struct CounterState: Equatable {
    internal var number: Int
    internal var isMinusButtonEnabled: Bool {
        number > 0
    }
}

internal enum CounterAction: Equatable {
    case didTapMinus
    case didTapPlus
}

internal let counterReducer = Reducer<CounterState, CounterAction, Void> { state, action, _ in
    switch action {
    case .didTapMinus:
        state.number -= 1
        return .none
    case .didTapPlus:
        state.number += 1
        return .none
    }
}
