//
//  OrderEnvironment+Mock.swift
//  TCABootcampTests
//
//  Created by jefferson.setiawan on 21/06/22.
//

import RxComposableArchitecture
import RxSwift
import SharedUI

extension OrderEnvironment {
    internal static let mockSuccess = Self(
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
}
