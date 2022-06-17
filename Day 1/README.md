# Day 1: The basics: State, Action, Side Effect, Environment

Pre-Bootcamp
Please checkout to this branch: `bootcamp`

Generate project: 
```
tools/tulsi_generate.sh ios/TCABootcamp/TCABootcampExample ios/TCABootcamp/TCABootcampTests
```

## Overview
In this lesson, you'll learn how to use:
- State 
- Action
- Side Effect & Environment

[Slides](https://www.icloud.com/keynote/0e4wY65J0Qlt8s86UX6kKpomw#TCA_Bootcamp)

## Quantity Editor for Order


![Demo Quantity Editor](Assets/0-start.gif "Quantity Editor")

VC: `CounterVC.swift`

Reducer: `CounterVC+Reducer.swift`

### Exercise 1: Disable on Minus Button
We want to make sure the quantity cannot be negative, so at the first run, we will disabled the minus button if the number <= 0.

![Disable Minus Button](Assets/1-disabled_button.gif "Disable Minus Button")

There are 2 ways to do achieve the requirement.

The first one is by adding a new property in the State:
```swift
internal struct CounterState: Equatable {
    internal var number: Int
    internal var isMinusButtonEnabled: Bool = false
}
```
In the reducer, we add a new check when user tap the minus button:
```swift
switch action {
case .didTapMinus:
    state.number -= 1
    state.isMinusButtonEnabled = state.number > 0
    return .none
case .didTapPlus:
    state.number += 1
    state.isMinusButtonEnabled = state.number > 0
    return .none
}
```

Run the app and you notice a strange behavior, because we first open the page, the number is set to 1, and the `isMinusButtonEnabled` is default to `false`.

Can someone give idea to fix this issue? 🙋🏻‍♂️

... (continue giving options)

To fix this we can use custom initialization on the `CounterState`:
```swift
internal struct CounterState: Equatable {
    internal var number: Int
    internal var isMinusButtonEnabled: Bool

    init(number: Int) {
    	self.number = number
    	self.isMinusButtonEnabled = number > 0
    }
}
```

The bug is gone 😃, but maybe some of you will think, this is not a DRY(don't repeat yourself), we repeat the `isMinusButtonEnabled = state.number > 0` 3 times!
You can refactor it to a function or maybe use `didSet` to watch whenever the `number` is changed. 
```swift
internal var number: Int {
    didSet {
        isMinusButtonEnabled = number > 0
    }
}
```

But remember, the `didSet` will NOT get called on initialization. so you need to do the check when in first init.
```swift
internal struct CounterState: Equatable {
    internal var number: Int {
        didSet {
            setMinusEnabledStatus()
        }
    }
    internal var isMinusButtonEnabled: Bool = false

    init(number: Int) {
        self.number = number
        setMinusEnabledStatus()
    }
    
    mutating func setMinusEnabledStatus() {
        self.isMinusButtonEnabled = number > 0
    }
}
```

The other approach is by leveraging the swift computed property 👍🏻
```swift
internal struct CounterState: Equatable {
    internal var number: Int
    internal var isMinusButtonEnabled: Bool { number > 0 }
}
```
By using computed property, there is no repeatition on the code. Usually we used computed property in TCA only if the property is just derived from the other property (in this case the enabled/disabled status is derived from the `number` property).

Next, let's re-run the test.
Strangely the test still green ✅ even though we add new property.
Why???
This is because computed properties are get only property, so you can't set into it. For example like this:

```swift
internal func testTapPlus() {
    // let testStore = ...
    
    testStore.send(.didTapPlus) {
        $0.isMinusButtonEnabled = false
    }
}
```

You'll get this error:
```
❌ Cannot assign to property: 'isMinusButtonEnabled' is a get-only property
```

To test this, you can use usual XCTAssert like this:
```swift
testStore.send(.didTapPlus) {
    XCTAssertTrue($0.isMinusButtonEnabled)
}
```

But that could be repetitive, for example when you tapMinus, to make sure that the value is correct, you add the similar code to assert the `isMinusButtonEnabled`.

The better way to test this, is by testing the plain state without involving the TCA.
```swift
internal func testEnabledMinusButton() {
    var state = CounterState(number: 1)
    
    XCTAssertTrue(state.isMinusButtonEnabled)
    
    state.number = 0
    
    XCTAssertFalse(state.isMinusButtonEnabled)
}
```

⚠️ Don't abuse computed property ⚠️

There are some cons of computed property which are:
1. The code can't join the Exhaustive test on TCA TestStore (as it's getter only)
2. Can only observe the `State`. If the value is derived from other things (e.g. the Environment), you can't use computed property. 


