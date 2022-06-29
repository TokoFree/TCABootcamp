//
//  CartPageEnvironment+Mock.swift
//  _idx_TCABootcamp_5E32A508_ios_min12.0
//
//  Created by jefferson.setiawan on 29/06/22.
//

import RxComposableArchitecture
import RxSwift

extension CartPageEnvironment {
    internal static let mockSuccess = Self(
        getCartData: {
            Effect(value: .success([.mock1, .mock2, .mock3, .mock4, .mock5]))
                .delay(.seconds(1), scheduler: MainScheduler.instance)
                .eraseToEffect()
        }
    )
    
    internal static let mockFailed = Self(
        getCartData: {
            Effect(value: .failure(.serverError))
        }
    )
}

extension ShopProductState {
    internal static let mock1 = ShopProductState(id: 1, name: "iPhone 13", price: 10_000_000, quantity: 1, isActive: true)
    internal static let mock2 = ShopProductState(id: 2, name: "iPhone 13 Pro Max", price: 20_000_000, quantity: 2, isActive: false)
    internal static let mock3 = ShopProductState(id: 3, name: "iPhone X", price: 4_000_000, quantity: 1, isActive: true)
    internal static let mock4 = ShopProductState(id: 10, name: "Book number 1", price: 70_000, quantity: 2, isActive: true)
    internal static let mock5 = ShopProductState(id: 11, name: "Book number 2", price: 170_000, quantity: 1, isActive: false)
}
