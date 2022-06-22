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
            XCTAssertTrue($0.isMinusButtonEnabled)
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

    internal func testChangeTextNumeric() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: ()
        )

        testStore.send(.textDidChange("10")) {
            $0.number = 10
        }
    }

    internal func testChangeTextToNonNumeric() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: ()
        )

        testStore.send(.textDidChange("a")) {
            $0.number = 0
            $0.errorMessage = "Should only contains numeric"
        }
    }

    internal func testChangeToNegativeByButton() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: ()
        )

        testStore.send(.textDidChange("-2")) {
            $0.number = -2
            $0.errorMessage = "Error, should >= 0"
        }
        testStore.send(.didTapPlus) {
            $0.number = -1
            $0.errorMessage = "Error, should >= 0"
        }
    }
}
