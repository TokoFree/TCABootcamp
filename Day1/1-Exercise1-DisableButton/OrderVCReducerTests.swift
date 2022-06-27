//
//  OrderVCReducerTests.swift
//  TCABootcampTests
//
//  Created by module_generator on 16/06/22.
//  Copyright © 2022 Tokopedia. All rights reserved.
//

import RxComposableArchitecture
import TestSupport
import XCTest

@testable import TCABootcamp

internal final class OrderVCReducerTests: XCTestCase {
    internal func testTapPlus() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: ()
        )

        testStore.send(.didTapPlus) {
            $0.number = 2
        }
    }

    internal func testTapMinus() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: ()
        )

        testStore.send(.didTapMinus) {
            $0.number = 0
        }
    }

    internal func testEnabledMinusButton() {
        var state = OrderState(number: 1)

        XCTAssertTrue(state.isMinusButtonEnabled)

        state.number = 0

        XCTAssertFalse(state.isMinusButtonEnabled)
    }
}
