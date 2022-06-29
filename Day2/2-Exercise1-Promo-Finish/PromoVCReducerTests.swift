//
//  PromoVCReducerTests.swift
//  TCABootcampTests
//
//  Created by jefferson.setiawan on 29/06/22.
//

import RxComposableArchitecture
import TestSupport
import XCTest

@testable import TCABootcamp

internal final class PromoVCReducerTests: XCTestCase {
    internal func testDidLoad() {
        let testStore = TestStore(
            initialState: PromoListState(),
            reducer: promoListReducer,
            environment: .failing
        )

        testStore.environment.getPromoList = {
            Effect(value: PromoState.mocks(numberOfMocks: 2))
        }

        testStore.send(.didLoad)
        testStore.receive(.receivePromoListResponse(PromoState.mocks(numberOfMocks: 2))) {
            $0.promos = IdentifiedArrayOf(PromoState.mocks(numberOfMocks: 2))
        }
    }
    
    internal func testFirstLoadWithPreselectedPromo() {
        let testStore = TestStore(
            initialState: PromoListState(selectedPromoId: "2"),
            reducer: promoListReducer,
            environment: .failing
        )

        testStore.environment.getPromoList = {
            Effect(value: PromoState.mocks(numberOfMocks: 2))
        }

        testStore.send(.didLoad)
        testStore.receive(.receivePromoListResponse(PromoState.mocks(numberOfMocks: 2))) {
            $0.promos = IdentifiedArrayOf(PromoState.mocks(numberOfMocks: 2))
            $0.promos[id: "2"]!.isSelected = true
        }
    }
    
    internal func testTapPromo() {
        let testStore = TestStore(
            initialState: PromoListState(promos: IdentifiedArrayOf(PromoState.mocks(numberOfMocks: 3))),
            reducer: promoListReducer,
            environment: .failing
        )
            
        testStore.send(.promo(id: "2", action: .didTap)) {
            $0.promos[id: "2"]!.isSelected = true
        }
    }
    
    internal func testTapPromoFlow() {
        let testStore = TestStore(
            initialState: PromoListState(promos: IdentifiedArrayOf(PromoState.mocks(numberOfMocks: 3))),
            reducer: promoListReducer,
            environment: .failing
        )
            
        testStore.send(.promo(id: "3", action: .didTap)) {
            $0.promos[id: "3"]!.isSelected = true
        }
        
        testStore.send(.didTapUsePromo) {
            $0.selectedPromoId = "3"
        }
        
        testStore.send(.promo(id: "3", action: .didTap)) {
            $0.promos[id: "3"]!.isSelected = false
        }
        
        testStore.send(.didTapUsePromo) {
            $0.selectedPromoId = nil
        }
    }
}

extension PromoListEnvironment {
    internal static let failing = Self(
        getPromoList: {
            Effect.failing("Should not called getPromoList")
        }
    )
}
