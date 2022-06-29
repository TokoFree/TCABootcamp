//
//  CartPageVC+Reducer.swift
//  _idx_TCABootcamp_5E32A508_ios_min12.0
//
//  Created by jefferson.setiawan on 29/06/22.
//

import RxComposableArchitecture
import NetworkInterface

internal struct CartPageState: Equatable {
    internal var isLoading = true
    internal var networkError: NetworkError?
    internal var products: IdentifiedArrayOf<ShopProductState> = []
    internal var totalPrice: Int {
        products.reduce(into: 0) { partialResult, state in
            if state.isActive {
                partialResult += (state.quantity * state.price)
            }
        }
    }
}

internal enum ShopProductAction: Equatable {
    case didTapToggle
    case didTapPlus
    case didTapMinus
    case didTapDelete
    case textDidChange(String)
}

internal enum CartPageAction: Equatable {
    case didLoad
    case receiveCartData(Result<[ShopProductState], NetworkError>)
    case product(id: Int, action: ShopProductAction)
}

internal struct ShopProductState: Equatable, HashDiffable {
    internal var id: Int
    internal var name: String
    internal var price: Int
    internal var quantity: Int
    internal var isActive: Bool
}

internal let cartPageReducer = Reducer<CartPageState, CartPageAction, CartPageEnvironment> { state, action, env in
    switch action {
    case .didLoad:
        state.isLoading = true
        state.networkError = nil
        return env.getCartData()
            .map(CartPageAction.receiveCartData)
    case let .receiveCartData(result):
        state.isLoading = false
        switch result {
        case let .success(products):
            state.products = IdentifiedArrayOf(products)
            return .none
        case let .failure(error):
            state.networkError = error
            return .none
        }
    case let .product(id, .didTapToggle):
        state.products[id: id]?.isActive.toggle()
        return .none
    case let .product(id, .didTapPlus):
        state.products[id: id]?.quantity += 1
        return .none
    case let .product(id, .didTapMinus):
        state.products[id: id]?.quantity -= 1
        return .none
    case let .product(id, .didTapDelete):
        state.products.remove(id: id)
        return .none
    case let .product(id, .textDidChange(string)):
        state.products[id: id]?.quantity = Int(string) ?? 0
        return .none
    }
}

internal struct CartPageEnvironment {
    internal var getCartData: () -> Effect<Result<[ShopProductState], NetworkError>>
}
