# Day 2: The Rest of TCA

## KeyPath & CasePath

### Short story of KeyPath

Branch: `bootcamptca-day2/1-starting_point`

KeyPath is created to make the code more dynamic. We will not explained the detail of the KeyPath here, just a bit introduction before we introduce you to `CasePath`.

Let said we have the `SecureModel`

```swift
struct SecureModel {
    var userId: Int
    var name: String
    var age: Int
    var deviceToken: String
}
```

When we need to mutate the property, usually we did this:
```
var model = SecureModel(userId: 1, name: "John Doe", age: 25, deviceToken: "myToken")
// to get value
print(model.deviceToken)

// to update value
model.deviceToken = "New Updated Token"
```

The other way to modify the property is by using KeyPath. E.g:

```swift
let deviceTokenKeyPath = \SecureModel.deviceToken // type: WritableKeyPath<SecureModel, String>

// to get value
print(model[keyPath: deviceTokenKeyPath])

// to update value
model[keyPath: deviceTokenKeyPath] = "New Updated Token from Keypath" // Write
```

It's more difficult than the usual way (direct mutate), so what the purpose of KeyPath? The keyword is "dynamic". Let's check our simplified `SecureStorage` class that storing the sensitive data in the keychain.

```swift
class SecureStorage {
    private var model = SecureModel(userId: 1, name: "John Doe", age: 25, deviceToken: "myToken")
    func getSecureData() -> SecureModel {
        return model
    }
}
```

This class/struct is used in many places (networking, user notification, user profile, etc). All the properties is stored in the single model (SecureModel).
Let said the UserNotification page want to update the deviceToken. This page doesn't care about other property. If you using usual way of get and mutate the property, you need to add function to mutate the deviceToken inside the SecureStorage class like this.

```swift
class SecureStorage {
	// ...
	func updateDeviceToken(newToken: String) {
		model.deviceToken = newToken
	}
}
```

and you need to provide function for all the property, such as userId, name, and age. You need `N` number of function on `N` properties. Previously this can be fixed by change the SecureModel to a dictionary.

```swift
class SecureStorage {
	var model: [String: Any]

	func update(key: String, value: Any) {
		model[key] = value
	}
}

// usage
SecureStorage().update(key: "deviceToken", value: "New Token Value")
```

But as you may know, the dictionary is not type safe. What happen when the key is not found when you are trying to get? What happen when you make typo, for example you want to update the `deviceToken`, but you type `devicetoken` (without capital `T` in token). What if you store the wrong value in that key? You need to cast to your intended value (such as `as? String` or `as? MyModel`). The compiler can't check the validity of the type

This is one of the use case I found that is a good candidate to use KeyPath.

```swift
class SecureStorage {
    private var model = SecureModel(userId: 1, name: "John Doe", age: 25, deviceToken: "myToken")
    func getSecureData() -> SecureModel {
        return model
    }
    
    func setSecureData<Value>(keyPath: WritableKeyPath<SecureModel, Value>, value: Value) {
        print("try to change \(keyPath) to \(value)")
        model[keyPath: keyPath] = value
    }
}
```

Using KeyPath, the compiler can type check the key and the value, so you'll never get the issue of miss type or miss add/update value on the specific key.

```swift
let secureManager = MySecureData()
print(secureManager.getData(keyPath: \.deviceToken))
secureManager.setSecureData(keyPath: \.deviceToken, value: "new Token")
print(secureManager.getData(keyPath: \.deviceToken))
```

Will print:
```
myToken
try to change Swift.WritableKeyPath<TCABootcamp.SecureModel, Swift.String> to new Token
new Token
```

The summary is, keyPath is used to store the metadata of Key and Value so we can dynamicly get and update the property.

### CasePath
CasePath is created by PointFree team to achieve the same thing as KeyPath.
As Apple still doesn't have the KeyPath for enum.

I still can't find the great usage in my mind to explained to you guys how the CasePath can help with the code.

So I'll explained what the main point of CasePath is by showing this code.

```swift
struct ShopRegular {
    var shopId: Int
    var name: String
}

struct ShopPowerMerchant {
    var shopId: Int
    var benefit: [String]
}

struct ShopOfficialStore {
    var shopId: Int
    var adminIds: [Int]
    var closedTime: String
}

enum ShopType {
    case regular(ShopRegular)
    case powerMerchant(ShopPowerMerchant)
    case officialStore(ShopOfficialStore)
}
```

The CasePath main function is the same as keyPath, which is:
1. get (in CasePath, the terminology is `extract`). You `extract` the `ShopType` to get the `ShopRegular`
2. set (in CasePath, it is `embed`). You `embed` the `ShopRegular` inside the `ShopType`

Let said we want to do something when the shopType is regular. how do you get and set the value to the `ShopType`?

```swift
func changeShopNameIfRegular(_ shopType: inout ShopType) {
	// get
	guard case var .regular(shopRegular) = shopType else { return nil }

	shopRegular.name = "UpdatedName"

	// set
	shopType = .regular(shopRegular)
}

var regularShopType = ShopType.regular(ShopRegular.mock)
changeShopNameIfRegular(&regularShopType)
print(regularShopType) // the name will change to "UpdatedName"

var officialStoreType = ShopType.officialStore(ShopOfficialStore.mock)
changeShopNameIfRegular(&regularShopType)
print(officialStoreType) // will not change
```

Let's try to use CasePath for the `changeShopNameIfRegular` function.
```swift
func changeShopNameIfRegular(_ shopType: inout ShopType) {
	// get
	guard var shopRegular = (/ShopType.regular).extract(from: shopType) else { return nil }

	shopRegular.name = "UpdatedName"

	// set
	shopType = (/ShopType.regular).embed(shopRegular)
}
```

The code is similar, so what's the benefit? The same as KeyPath, if you do the specific things, there is no huge benefit of using CasePath. The benefit is more clear when you are doing more broad helper, for example the modify

```swift
extension CasePath {
  public func modify<Result>(
    _ root: inout Root,
    _ body: (inout Value) throws -> Result
  ) throws -> Result {
    guard var value = self.extract(from: root) else { throw ExtractionFailed() }
    let result = try body(&value)
    root = self.embed(value)
    return result
  }
}
```

That function can be used for every CasePath we have, let's update our `changeShopNameIfRegular` to uses the new `modify` helper.

```swift
func changeShopNameIfRegular(_ shopType: inout ShopType) {
	try? (/ShopType.regular).modify(&shopType) {
        // modify
        $0.name = "Updated Name using CasePath modify"
    }
}
```

The code is much much simpler, because of the generic CasePath that know how to get (extract) and set (embed), the modify function can do both of them automatically, and you can focus on modifying the value.

The CasePath will used multiple times in our upcoming demos and exercises.

## ForEachStoreNode: Handling list of items never been this easy!

![Demo ForEachStoreNode](Assets/1-demo-foreachstorenode.gif)

On the demo page, you can see we do the CRUD (Create read update delete) from the list of items.

First we tried to create the page manually using the array of Nodes encapsulated by `ASScrollNode`.

You can see the code in the `ManualLoopVC.swift` and focus on the `updateState` function.

```swift
private func updateState(state: ManualLoopModel) {
    self.state = state
    nodes = state.items.map { item in
        let node = ManualTextNode(state: item)
        node.onTapToggle = { [weak self] in
            self?.setSelected(id: item.id)
        }
        node.onTapRemove = { [weak self] in
            self?.remove(id: item.id)
        }
        return node
    }
    scrollNode.setNeedsLayout()
}
```

The code will called everytime you change the `state`, to keep the UI sync with the state. This code is not efficient, as if you do something on the state, it'll create the whole new nodes. To improve the code, you need to add extra logic to diffing the old and new value, and only rerender/update on the node that has different value from the old one.

That logic could be difficult and repeated by other feature/developers. This is one of the reason why we create ForEachStoreNode.

ForEachStoreNode is a node that uses store as its backbone and will handle the diffing for you automatically.

Let's try to convert it to use ForEachStoreNode.

First, we set the State.
```swift
struct DemoForEachState: Equatable {
    var stackData: IdentifiedArrayOf<DemoItemState> = []
    var lastId: Int = 0 // used for keep tracking of the last id
}

struct DemoItemState: Equatable, HashDiffable {
    var id: Int
    var text: String
    var isActive: Bool
}
```

There is new type of data: `IdentifiedArray`.

IdentifiedArray is commonly used in collection of TCA because it's like the Array with the benefit of accessing the ids like Dictionary. 

Let's try it:
```swift
var states = DemoItemState.mocks(numberOfMocks: 10)
var identifiedArrayStates = IdentifiedArrayOf(DemoItemState.mocks(numberOfMocks: 10))

// modify states of id 2
if let index2 = states.firstIndex(where: { $0.id == 2 }) {
    states[index2].isActive.toggle()
}
identifiedArrayStates[id: 2]?.isActive.toggle()

// removing id 3
states.removeAll { $0.id == 3 }
identifiedArrayStates.remove(id: 3)
```

In regular array the complexity of modify and removing the item by our identifier is O(n), on the other hand, it just O(1) on IdentifiedArray.

The next one is `HashDiffable`. `HashDiffable` is a protocol that very similar to `Identifiable` protocol that swift introduce on iOS 13. Because we still support iOS 12, we create that protocol so the code in the ForEachStoreNode will know how to do the diffing.

Let's move on to the Action.

```swift
internal enum DemoForEachAction: Equatable {
    case didLoad
    case shuffle
    case addItem
    case child(id: Int, action: DemoItemAction)

    /// Side Effect
    case receiveData([DemoItemState])
}
```

We can focus on the `case child`, because this is the new pattern that will heavyly used on array of store (ForEachStoreNode).

The pattern is for array of store action, we provide the id, and the node Action.

The type of id is depend on its State id counterpart. (in this case the `DemoItemState`'s id is `Int`, so we make the id `Int`)

The id is needed so you will know in which state the action is performed.

Next, let's implement the reducer:
```swift
let demoForEachReducer = Reducer<DemoForEachState, DemoForEachAction, DemoForEachEnvironment> { state, action, env in
    switch action {
    case .didLoad:
        return env.loadData()
            .map(DemoForEachAction.receiveData)
            .eraseToEffect()
    case let .receiveData(data):
        state.stackData = IdentifiedArray(data)
        state.lastId = data.count
        return .none
    case .shuffle:
        state.stackData.shuffle()
        return .none
    case .addItem:
        state.lastId += 1
        state.stackData.append(DemoItemState(
            id: state.lastId,
            text: "Data \(state.lastId)",
            isActive: true
        ))
        return .none
    case let .child(id, .remove):
        state.stackData.remove(id: id)
        return .none
    case let .child(id, .toggle):
        state.stackData[id: id]?.isActive.toggle()
        return .none
    }
}
```

The logic has been finished. Let's move on the UI `DemoItemNode` first.
Let's convert `ManualTextNode` to the DemoItemNode, you can copy the implementation to the `DemoForEachVC.swift` and change the name of the class to `DemoItemNode`.

Then change the init to using `Store<DemoItemState, DemoItemAction>`, then change the binding to use the store.

```swift
private func bindState() {
    store.subscribe(\.text)
        .map { NSAttributedString.body2($0) }
        .asDriverOnErrorJustComplete()
        .drive(textNode.rx.attributedText)
        .disposed(by: rx.disposeBag)

    store.subscribe(\.isActive)
        .asDriverOnErrorJustComplete()
        .drive(onNext: { [isActiveButton] isActive in
            isActiveButton.setTitle(isActive ? "✅" : "❌", with: .body1(), with: .n700A96, for: .normal)
            self.setNeedsLayout()
        })
        .disposed(by: rx.disposeBag)
}

private func bindAction() {
    isActiveButton.rx.tap.asDriverOnErrorJustComplete()
        .drive(onNext: { [store] in
            store.send(.toggle)
        })
        .disposed(by: rx.disposeBag)

    removeButton.rx.tap.asDriverOnErrorJustComplete()
        .drive(onNext: { [store] in
            store.send(.remove)
        })
        .disposed(by: rx.disposeBag)
}
```

Let's go to main portion, implementing the `ForEachStoreNode`.

When creating the ForEachStoreNode, we need three things:
```swift
public convenience init(
    store: Store<State, (State.Element.IdentifierType, Action)>,
    layoutSpecOptions: LayoutSpecOptions = .init(),
    node: @escaping (Store<State.Element, Action>) -> ASDisplayNode
)
```

Let's talk about one by one:
- store: `Store<State, (State.Element.IdentifierType, Action)>`

The `State` type should be a `Collection` (as its stated in the init type constraint). the action is a tuple `(State.Element.IdentifierType, Action)`, if you may remember, this is the same pattern we used on the action `child`.
```swift
case child(id: Int, action: DemoItemAction)
```
The id is the State.Element.IdentifierType which is `Int`. and the action is `DemoItemAction`.
- layoutSpecOptions is a parameter to configure the layouting (such as spacing, direction, etc)
- node: The closure that convert the given `Store` to the node. The Store type is `Store<State.Element, Action>`, in this demo the State.Element is `DemoItemState` and the action is `DemoItemAction`

```swift
private lazy var nodes = ForEachStoreNode(
    store: self.store.scope(
        state: \.stackData,
        action: DemoForEachAction.child
    ),
    layoutSpecOptions: LayoutSpecOptions(stackDirection: .vertical)
) { eachStore in
    DemoItemNode(store: eachStore)
}
```

You can further simplify the code to:
```swift
private lazy var nodes = ForEachStoreNode(
    store: self.store.scope(
        state: \.stackData,
        action: DemoForEachAction.child
    ),
    layoutSpecOptions: LayoutSpecOptions(stackDirection: .vertical),
    node: DemoItemNode.init
)
```

## Exercise 1: Promo List Page

![Promo List Page](Assets/2-promo-list.gif)

We've provide skeleton of the UI. So you can focus on the TCA part.
File: `PromoListVC.swift`




## ListStoreNode

Example: Change the `DemoForEachNode` to using `ListStoreNode`
Exercise: Cart with multiple products

### When to use ForEachStoreNode and ListStoreNode

If you have lots of item and need Collection functionality, please use `ListStoreNode`, otherwise you can choose both of them.

## Reducer.forEach
Example: DemoForEachVC
Exercise: PromoListVC

## Reducer.pullback
Demo: ???
Exercise: ???

## Reducer.optional
Demo: ???
Exercise: Adding promo bottom sheet in the Cart page.

## ListStoreNode with SwitchCaseStoreNode
Demo: ???
Exercise: ???

## Enum State & SwitchCaseStoreNode
Demo: 
Exercise 1: OrderVC
Exercise 2: CartPage