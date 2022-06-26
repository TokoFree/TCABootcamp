//
//  OrderEnvironment+Mock.swift
//  TCABootcampTests
//
//  Created by jefferson.setiawan on 21/06/22.
//

import RxComposableArchitecture
import RxSwift
import SharedUI

internal struct ProductInfo: Equatable {
    internal var id: Int
    internal var name: String
    internal var price: Int
    internal var description: String
    internal var isWishlist: Bool
}

extension ProductInfo {
    internal static var mock = Self(
        id: 1,
        name: "iPhone 13 Pro Max 64GB",
        price: 13_000_000,
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vel elementum nisl, a consequat odio. Sed sed suscipit magna. Nulla non lorem non quam tristique dapibus sed et nulla. Nam mollis ultricies orci, vel vulputate sem hendrerit tempus. Duis volutpat justo arcu, nec tristique tellus porta vitae. Etiam ac erat quis erat consequat convallis. Integer vel laoreet eros. Sed iaculis sed nibh varius elementum. Ut sit amet urna sit amet ligula suscipit fringilla sed a felis. Nam mollis rhoncus massa. Quisque ac volutpat erat. Etiam lobortis metus iaculis, varius arcu id, luctus felis.",
        isWishlist: false
    )
}

extension OrderEnvironment {
    internal static let mockSuccess = Self(
        getProductInfo: {
            Effect(value: .success(.mock))
                .delay(.seconds(2), scheduler: MainScheduler.instance)
                .eraseToEffect()
        },
        submitOrder: { _ in
            Effect(value: true)
        },
        showToast: { message in
            .fireAndForget {
                Toast.shared.display(message: message)
            }
        }
    )

    internal static let mockFailedIfNumber5 = Self(
        getProductInfo: {
            Effect(value: .success(.mock))
                .delay(.seconds(2), scheduler: MainScheduler.instance)
                .eraseToEffect()
        },
        submitOrder: {
            Effect(value: $0 != 5)
                .delay(.seconds(1), scheduler: MainScheduler.instance)
                .eraseToEffect()
        },
        showToast: { message in
            .fireAndForget {
                Toast.shared.display(message: message)
            }
        }
    )
    
    internal static let mockFailed = Self(
        getProductInfo: {
            Effect(value: .failure(.serverError))
                .delay(.seconds(2), scheduler: MainScheduler.instance)
                .eraseToEffect()
        },
        submitOrder: { _ in
            Effect(value: false)
                .delay(.seconds(1), scheduler: MainScheduler.instance)
                .eraseToEffect()
        },
        showToast: { message in
            .fireAndForget {
                Toast.shared.display(message: message)
            }
        }
    )
}
