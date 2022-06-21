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

### Exercise 2: Enable Text Input & Add Error Message

![Add Keyboard input and Error Message](Assets/2-keyboard-input-and-error-message.gif "Add Keyboard input and Error Message")

Next, we will enable keyboard input on the `TextFieldNode`. You can remove the `isEnabled = false` on `TextFieldNode`.
Then you can listen to the text changed and send it as action to the reducer.
```swift
enum CounterAction: Equatable {
    // ...
    case textDidChange(String)
}

func bindAction() {
    // ...
    textFieldNode.rx.text
        .asDriver()
        .drive(onNext: { [store] text in
            store.send(.textDidChange(text))
        })
        .disposed(by: rx.disposeBag)
}

// Reducer
case let .textDidChange(string):
    state.number = Int(string) ?? 0
```

Because the number type is `Int`, we need to only allow numeric type, if the input is invalid, we will add `errorMessage` that will shown to the user as TextField's `errorMessage` property.

```swift
struct CounterState {
    var errorMessage: String?
}

// Reducer
case let .textDidChange(string):
    if let number = Int(string) {
        state.number = number
        state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
    } else {
        state.number = 0
        state.errorMessage = "Should only contains numeric"
    }
    return .none
```

Run the app, and if you try it, you may find a bug related to the errorMessage, which is in case when you are typing negative value e.g. -2, and then using paste, change to another negative value (such as -1), the errorMessage is gone!

Why this happen? We never make the `errorMessage` property to nil 🤔
Turns out, TextFieldNode will reset the errorMessage everytime you change the text behind the scene. This lead to problem on UI that is out of sync from the state which is our source of truth.

But don't worry, we have added a `shouldResetErrorMessageAfterTyping` property to cater this problem, please set it to `false`, so the `TextFieldNode` will not reset the `errorMessage` without our consent (our State).

Every number change, we need to check the number error state. Please add below code on every action that mutate the `number`.

```swift
state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
```

This is not good, we repeat everytime we change the number. But we can't use computed property because we have 2 cases on showing errorMessage, valid 0 will not returning error, but 0 because of invalid non numeric should show the error.

We will give several ways to fix this:
1. Using side effect ❌
```swift
enum CounterAction {
    // ...
    case checkNumber
}

// Reducer
let counterReducer = Reducer<CounterState, CounterAction, Void> { state, action, env in
    switch action {
    case .didTapMinus:
        state.number -= 1
        return Effect(value: .checkNumber)
    case .didTapPlus:
        state.number += 1
        return Effect(value: .checkNumber)
    case let .textDidChange(string):
        if let number = Int(string) {
            state.number = number
            return Effect(value: .checkNumber)
        } else {
            state.number = 0
            state.errorMessage = "Should only contains numeric"
            return .none
        }
    case .checkNumber:
        state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
        return .none
    }
}
```

There is no more repeatition, next, lets fix the unit test.
```swift
internal func testTapPlus() {
    let testStore = TestStore(
        initialState: CounterState(number: 1),
        reducer: counterReducer,
        environment: ()
    )

    testStore.send(.didTapPlus) {
        $0.number = 2
        XCTAssertTrue($0.isMinusButtonEnabled)
    }
    testStore.receive(.checkNumber)
}

internal func testChangeTextToNonNumeric() {
    let testStore = TestStore(
        initialState: CounterState(number: 1),
        reducer: counterReducer,
        environment: ()
    )

    testStore.send(.textDidChange("a")) {
        $0.number = 0
        $0.errorMessage = "Should only contains numeric"
    }
}
```

The problem of this approach is the test will have lots of .receive noise. This will make our test less readable by other devs, maybe for this simple case, it still readable, but in more complex case, it can make your test flow more difficult to read. Naturally, the action should represent what users do and side effects. If you read the test above, it's readed like: user tapPlus, then user check the number, which is incorrect.

Let's move to the next approach:

2. Inline function ✅
Next approach is by using function that live inside the reducer. 
```swift
let counterReducer = Reducer<CounterState, CounterAction, Void> { state, action, _ in
    func validateNumber() {
        state.errorMessage = state.number < 0 ? "Error, should >= 0" : nil
    }
    switch action {
    case .didTapMinus:
        state.number -= 1
        validateNumber()
        return .none
    // ...
    }
```

The refactor is still the same, you only need to call the function, but there is no need to return it as side effect.

So our test will be more straightforward, you can remove all the `checkNumber` side effects.

```swift
internal func testChangeToNegativeByButton() {
    let testStore = TestStore(
        initialState: CounterState(number: 1),
        reducer: counterReducer,
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
```

This approach are widely used because you can still use the environment.

The last approach is by creating a function inside the State itself.

3. State function ✅
```swift
struct CounterState {
    // ..

    mutating func validateNumber() {
        errorMessage = number < 0 ? "Error, should >= 0" : nil
    }
}

// Reducer
state.validateNumber()
```

By using this style, you can call it on other place that uses this State (for example if you need to call it on other reducers), but you can't use environment (if you need to you can still pass it as the function argument).

We have another problem that not exists in MVVM (hint: this is related to the distinctUntilChanged in TCA).

To demonstrate the problem, let change the text using non numeric character (such as `a`), then the reducer will change the number into `0` and it's reflected into the UI.

Let's change it again into non numeric character, the state still `0`, but the UI will change to `0a`

Why this happen? Let's try to debug it 🛠
First, we can try add .debug() at the end of our reducer.
```swift
let counterReducer = Reducer<CounterState, CounterAction, Void> { 
}.debug()
```

In the log you can see all the action send and the state that changed to the reducer 
```
received action:
  CounterAction.textDidChange(
    "1"
  )
  (No state changes)

// change to a
received action:
  CounterAction.textDidChange(
    "A"
  )
  CounterState(
−   number: 1,
−   errorMessage: nil
+   number: 0,
+   errorMessage: "Should only contains numeric"
  )

// type another 'a'
received action:
  CounterAction.textDidChange(
    "0a"
  )
  (No state changes)

```

Seeing the xcode console log, the second time we type `a`, the `State` is still the same like previous, why the text field have different value 🤔? Ok, let's debug in the UI using infamous `print` statement in the subscription of the number state.

```swift
store.subscribe(\.number)
    .subscribe(onNext: { [textFieldNode] text in
        print("<<< \(number)")
        textFieldNode.text = String(text)
    })
    .disposed(by: rx.disposeBag)
```
Let's run the app again, and replicate the steps
```
<<< 1 // when open the page
<<< 0 // type 'a'
```

We only see 2 value being emitted which you might thing this is strange. 

Don't worry, we will explain why this happen. 
Let's deep dive about how the TCA subscription works compare to our MVVM.

![MVVM Stream Flow](Assets/MVVM.gif "MVVM Stream Flow")

In MVVM, each output has its own Observable, so everytime you send (onNext) on it, it will produce new stream.

![TCA Stream Flow](Assets/tca.gif "TCA Stream Flow")
On contrary, TCA has 1 single Observable which is the `State`. So it needs to do the distinct (using `distinctUntilChanged`) so it will emit new value when it's not equal.

That's explains why when the value is still the same, the subscription will not emit new `onNext` value.

Maybe some of you still questioning, why TCA need the distinction.
I'll create example flow in case we don't use distinct in the TCA subscription.
![TCA Stream with No Distinct Flow](Assets/tca_non_distinct.gif "TCA Stream with No Distinct Flow")

As you can see, everytime the State change, it will emit to all the part of the subscription, eventhough we don't touch the property in the reducer. It causes unnecessary subscription emit and run.

As we approaching the Declarative UI, this is what we need to think, as State will be our source of truth, then if the value is same, we'll not do anything.

The problem arise because we are using the UIKit/Texture that are still imperative, the `TextFieldNode` still have it's own state. Our state is `0`, but TextField state is `0a`. This problem will not arise when you are using declarative framework UI such as SwiftUI or other declarative UI (such as Vue, Redux).

Fortunately, this is rarely happen, and we found an idea to cater this problem, using brand new `NeverEqual` property wrapper.

## NeverEqual
NeverEqual is created to cater the problem above.



## Environment


### Exercise 3: Add Create Order Button
// TODO