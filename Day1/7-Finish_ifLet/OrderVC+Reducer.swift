//
//  OrderVC+Reducer.swift
//  _idx_TCABootcamp_46CB3511_ios_min12.0
//
//  Created by jefferson.setiawan on 16/06/22.
//

import NetworkInterface
import RxComposableArchitecture
import RxSwift

internal struct OrderState: Equatable {
    internal var productState: ProductState?
    internal var counterState: CounterState
}

internal enum OrderAction: Equatable {
    case didLoad
    case counter(CounterAction)
    case didTapAddOrder
    case receiveAddOrderResponse(Bool)
    case receiveProductInfo(Result<ProductInfo, NetworkError>)
}

internal struct OrderEnvironment {
    internal var getProductInfo: () -> Effect<Result<ProductInfo, NetworkError>>
    internal var submitOrder: (Int) -> Effect<Bool>
    internal var showToast: (String) -> Effect<Never>
}

internal let orderReducer = Reducer<OrderState, OrderAction, OrderEnvironment> { state, action, env in
    func validateNumber() {
        state.counterState.errorMessage = state.counterState.number < 0 ? "Error, should >= 0" : nil
    }
    switch action {
    case .didLoad:
        return env.getProductInfo()
            .map(OrderAction.receiveProductInfo)
    case let .receiveProductInfo(result):
        switch result {
        case let .success(info):
            state.productState = ProductState(id: info.id, name: info.name, price: info.price)
        case let .failure(error):
            print("error \(error)")
        }
        return .none
    case .counter(.didTapMinus):
        state.counterState.number -= 1
        validateNumber()
        return .none
    case .counter(.didTapPlus):
        state.counterState.number += 1
        validateNumber()
        return .none
    case let .counter(.textDidChange(string)):
        if let number = Int(string) {
            state.counterState.number = number
            validateNumber()
            return .none
        } else {
            state.counterState.number = 0
            state.counterState.errorMessage = "Should only contains numeric"
            return .none
        }
    case .didTapAddOrder:
        return env.submitOrder(state.counterState.number)
            .map(OrderAction.receiveAddOrderResponse)
    case let .receiveAddOrderResponse(isSuccess):
        if isSuccess {
            return env.showToast("Order created successfully")
                .fireAndForget()
        } else {
            state.counterState.errorMessage = "Submit Order Failed"
        }
        return .none
    }
}
