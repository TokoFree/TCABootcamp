//
//  CartPageVC+Reducer.swift
//  _idx_TCABootcamp_5E32A508_ios_min12.0
//
//  Created by jefferson.setiawan on 29/06/22.
//

import RxComposableArchitecture
import NetworkInterface

internal struct CartPageState: Equatable {
    internal var products: IdentifiedArrayOf<ShopProductState> = []
}

internal enum ShopProductAction: Equatable {
    case didTapPlus
    case didTapMinus
    case textDidChange(String)
}

internal enum CartPageAction: Equatable {
    case didLoad
}

internal struct ShopProductState: Equatable, HashDiffable {
    internal var id: Int
    internal var name: String
    internal var price: Int
    internal var quantity: Int
    internal var isActive: Bool
}

internal let cartPageReducer = Reducer<CartPageState, CartPageAction, CartPageEnvironment> { state, action, env in
    return .none
}

internal struct CartPageEnvironment {
    internal var getCartData: () -> Effect<Result<[ShopProductState], NetworkError>>
}
