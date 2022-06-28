# Day 2: The Rest of TCA

## KeyPath CasePath

### Short story of KeyPath
```swift
struct SecureModel {
    var userId: Int
    var name: String
    var age: Int
    var deviceToken: String
}

class MySecureData {
    private var model = SecureModel(userId: 1, name: "John Doe", age: 25, deviceToken: "asdnjq-ansjqnd-wndjq")
    func getSecureData() -> SecureModel {
        return model
    }
    
    func setSecureData<Value>(keyPath: WritableKeyPath<SecureModel, Value>, value: Value) {
        print("try to change \(keyPath) to \(value)")
        model[keyPath: keyPath] = value
    }
}
```

```swift
let secureManager = MySecureData()
print(secureManager.getData(keyPath: \.deviceToken))
secureManager.setSecureData(keyPath: \.deviceToken, value: "new Token")
print(secureManager.getData(keyPath: \.deviceToken))
```

Will print:
```
asdnjq-ansjqnd-wndjq
try to change Swift.WritableKeyPath<TCABootcamp.SecureModel, Swift.String> to new Token
new Token
```

## ForEachStoreNode

## ListStoreNode

## Reducer.forEach, Reducer.optional, pullback

## Enum State & SwitchCaseStoreNode