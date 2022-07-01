//
//  DemoPullbackVC+Reducer.swift
//  _idx_TCABootcamp_5E32A508_ios_min12.0
//
//  Created by jefferson.setiawan on 29/06/22.
//

import RxComposableArchitecture

internal struct DemoPullbackState: Equatable {
    internal var information: String
    internal var productCard: ProductCardState
}

internal enum DemoPullbackAction: Equatable {
    case didLoad
    case productCard(ProductCardAction)
}

internal struct DemoPullbackEnvironment {
    internal var route: (String) -> Effect<Never>
    internal var trackEvent: (String) -> Effect<Never>
}

extension DemoPullbackEnvironment {
    internal static let mock = Self(
        route: { url in
            .fireAndForget {
                print("will route to: ", url)
            }
        },
        trackEvent: { event in
            .fireAndForget {
                print("<<< tracking event of: \(event)")
            }
        }
    )
}

internal struct ProductCardState: Equatable {
    internal var id: Int
    internal var name: String
    internal var price: Int
    internal var isWishlist: Bool
    internal var url: String
}

extension ProductCardState {
    internal static let mock = Self(id: 1, name: "iPad Pro 13.3 inch", price: 12_000_000, isWishlist: false, url: "https://tokopedia.com/shop/iPad-Pro-13.3-inch")
}

internal enum ProductCardAction: Equatable {
    case didTap
    case didTapWishlist
}

internal struct ProductCardEnvironment {
    internal var route: (String) -> Effect<Never>
}

extension ProductCardEnvironment {
    internal static var mock = Self(route: { url in
        .fireAndForget {
            print("will route to: ", url)
        }
    })
}

internal let productCardReducer = Reducer<ProductCardState, ProductCardAction, ProductCardEnvironment> { state, action, env in
    switch action {
    case .didTap:
        return env.route(state.url)
            .fireAndForget()
    case .didTapWishlist:
        state.isWishlist.toggle()
        return .none
    }
}

private let defaultReducer = Reducer<DemoPullbackState, DemoPullbackAction, DemoPullbackEnvironment> { state, action, env in
    switch action {
    case .didLoad:
        return .none
    case .productCard(.didTap):
        return .none
    case .productCard(.didTapWishlist):
        return env.trackEvent("Tracking wishlist to: \(state.productCard.isWishlist)")
            .fireAndForget()
    }
}

internal let demoPullbackReducer = Reducer<DemoPullbackState, DemoPullbackAction, DemoPullbackEnvironment>.combine(
    productCardReducer.pullback(
        state: \.productCard,
        action: /DemoPullbackAction.productCard,
        environment: { ProductCardEnvironment(route: $0.route) }
    ),
    defaultReducer
)
