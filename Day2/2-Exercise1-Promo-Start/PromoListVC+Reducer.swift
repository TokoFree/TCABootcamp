//
//  PromoListVC+Reducer.swift
//  _idx_TCABootcamp_7583B6FD_ios_min12.0
//
//  Created by jefferson.setiawan on 28/06/22.
//

import RxComposableArchitecture
import RxSwift

internal struct PromoListState: Equatable {
    internal var selectedPromoId: String?
}

internal enum PromoListAction: Equatable {
    case didLoad
}

internal struct PromoListEnvironment {
    internal var getPromoList: () -> Effect<[PromoState]>
}

extension PromoListEnvironment {
    internal static let mock = Self(
        getPromoList: {
            Effect(value: PromoState.mocks(numberOfMocks: 20))
                .delay(.milliseconds(250), scheduler: MainScheduler.instance)
                .eraseToEffect()
        }
    )
}

extension PromoState {
    internal static func mocks(numberOfMocks: Int) -> [Self] {
        (1...numberOfMocks).map {
            Self(id: String($0), title: "Discount Rp \($0 * 10_000)", amount: $0 * 10_000)
        }
    }
}

internal let promoListReducer = Reducer<PromoListState, PromoListAction, PromoListEnvironment> { state, action, env in
    return .none
}
