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
    internal var isLoading = true
    internal var productState: ProductState?
    internal var counterState: CounterState
    internal var networkError: NetworkError?
    internal var isWishlist: Bool = false
    internal var showBottomSheet = false
    internal var bottomSheetState: ProductDetailState? {
        guard let productState = productState, showBottomSheet else {
            return nil
        }
        return ProductDetailState(name: productState.name, price: productState.price, description: productState.description, isWishlist: isWishlist)
    }
}

internal enum OrderAction: Equatable {
    case didLoad
    case counter(CounterAction)
    case didTapAddOrder
    case receiveAddOrderResponse(Bool)
    case receiveProductInfo(Result<ProductInfo, NetworkError>)
    case productInfo(OrderProductAction)
    case dismissBottomSheet
    case bottomSheet(ProductDetailAction)
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
        state.isLoading = false
        switch result {
        case let .success(info):
            state.productState = ProductState(id: info.id, name: info.name, price: info.price, description: info.description)
            state.isWishlist = info.isWishlist
        case let .failure(error):
            state.networkError = error
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
    case .productInfo(.didTap):
        guard let productState = state.productState else { return .none }
        state.showBottomSheet = true
        return .none
    case .dismissBottomSheet:
        state.showBottomSheet = false
        return .none
    case .bottomSheet(.didTapWishlist):
        state.isWishlist.toggle()
        return .none
    }
}
