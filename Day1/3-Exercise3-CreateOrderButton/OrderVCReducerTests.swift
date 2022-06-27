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
            environment: .failing
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
            environment: .failing
        )

        testStore.send(.didTapMinus) {
            $0.number = 0
        }
    }

    internal func testChangeTextNumeric() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.send(.textDidChange("10")) {
            $0.number = 10
        }
    }

    internal func testChangeTextToNonNumeric() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: .failing
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
            environment: .failing
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

    internal func testSubmitOrderSucceed() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: .failing
        )

        var toastSink: [String] = []

        testStore.environment.submitOrder = { _ in
            Effect(value: true)
        }

        testStore.environment.showToast = { message in
            .fireAndForget {
                toastSink.append(message)
            }
        }

        testStore.send(.didTapAddOrder)
        testStore.receive(.receiveAddOrderResponse(true))
        XCTAssertEqual(toastSink, ["Order created successfully"])
    }

    internal func testSubmitOrderFailed() {
        let testStore = TestStore(
            initialState: OrderState(number: 1),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.environment.submitOrder = { _ in
            Effect(value: false)
        }

        testStore.send(.didTapAddOrder)
        testStore.receive(.receiveAddOrderResponse(false)) {
            $0.errorMessage = "Submit Order Failed"
        }
    }
}

extension OrderEnvironment {
    internal static var failing = Self(
        submitOrder: { _ in
            .failing("Should not called submitOrder")
        },
        showToast: { _ in
            .failing("Should not called showToast")
        }
    )
}
