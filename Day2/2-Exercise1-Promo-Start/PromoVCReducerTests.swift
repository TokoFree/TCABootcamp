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
    }
}

extension PromoListEnvironment {
    internal static let failing = Self(
        getPromoList: {
            Effect.failing("Should not called getPromoList")
        }
    )
}
