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
    
    internal var selectedPromoState: PromoState? {
        selectedPromoId.flatMap { promos[id: $0] }
    }
    
    internal var promos: IdentifiedArrayOf<PromoState> = []
}

internal enum PromoListAction: Equatable {
    case didLoad
    case receivePromoListResponse([PromoState])
    case promo(id: String, action: PromoAction)
    case didTapUsePromo
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
    switch action {
    case .didLoad:
        return env.getPromoList()
            .map(PromoListAction.receivePromoListResponse)
    case let .receivePromoListResponse(promos):
        state.promos = IdentifiedArrayOf(promos)
        state.promos.mutateEach { promoState in
            promoState.isSelected = promoState.id == state.selectedPromoId
        }
        return .none
    case let .promo(id, .didTap):
        state.promos.mutateEach {
            if $0.id == id {
                $0.isSelected.toggle()
            } else {
                $0.isSelected = false
            }
        }
        return .none
    case .didTapUsePromo:
        state.selectedPromoId
        state.selectedPromoId = state.promos.first(where: \.isSelected)?.id
        return .none
    }
}
