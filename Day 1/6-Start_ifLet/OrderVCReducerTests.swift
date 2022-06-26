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
            initialState: OrderState(counterState: CounterState(number: 1)),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.send(.counter(.didTapPlus)) {
            $0.counterState.number = 2
        }
    }

    internal func testTapMinus() {
        let testStore = TestStore(
            initialState: OrderState(counterState: CounterState(number: 1)),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.send(.counter(.didTapMinus)) {
            $0.counterState.number = 0
        }
    }

    internal func testEnabledMinusButton() {
        var state = CounterState(number: 1)

        XCTAssertTrue(state.isMinusButtonEnabled)

        state.number = 0

        XCTAssertFalse(state.isMinusButtonEnabled)
    }

    internal func testChangeTextNumeric() {
        let testStore = TestStore(
            initialState: OrderState(counterState: CounterState(number: 1)),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.send(.counter(.textDidChange("10"))) {
            $0.counterState.number = 10
        }
    }

    internal func testChangeTextToNonNumeric() {
        let testStore = TestStore(
            initialState: OrderState(counterState: CounterState(number: 1)),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.send(.counter(.textDidChange("a"))) {
            $0.counterState.number = 0
            $0.counterState.errorMessage = "Should only contains numeric"
        }
    }

    internal func testChangeToNegativeByButton() {
        let testStore = TestStore(
            initialState: OrderState(counterState: CounterState(number: 1)),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.send(.counter(.textDidChange("-2"))) {
            $0.counterState.number = -2
            $0.counterState.errorMessage = "Error, should >= 0"
        }
        testStore.send(.counter(.didTapPlus)) {
            $0.counterState.number = -1
            $0.counterState.errorMessage = "Error, should >= 0"
        }
    }

    internal func testSubmitOrderSucceed() {
        let testStore = TestStore(
            initialState: OrderState(counterState: CounterState(number: 1)),
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
            initialState: OrderState(counterState: CounterState(number: 1)),
            reducer: orderReducer,
            environment: .failing
        )

        testStore.environment.submitOrder = { _ in
            Effect(value: false)
        }

        testStore.send(.didTapAddOrder)
        testStore.receive(.receiveAddOrderResponse(false)) {
            $0.counterState.errorMessage = "Submit Order Failed"
        }
    }
}

extension OrderEnvironment {
    internal static var failing = Self(
        getProductInfo: {
            .failing("Should not called getProductInfo")
        },
        submitOrder: { _ in
            .failing("Should not called submitOrder")
        },
        showToast: { _ in
            .failing("Should not called showToast")
        }
    )
}
