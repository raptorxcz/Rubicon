# Rubicon
[![Build Status](https://travis-ci.org/raptorxcz/Rubicon.svg?branch=master)](https://travis-ci.org/raptorxcz/Rubicon)
[![Build Status](https://codecov.io/gh/raptorxcz/Rubicon/branch/master/graph/badge.svg)](https://codecov.io/gh/raptorxcz/Rubicon)

Now available on AppStore [https://itunes.apple.com/cz/app/rubicon/id1238839496?mt=12](https://itunes.apple.com/cz/app/rubicon/id1238839496?mt=12)

Swift parser + mock generator

Rubicon generates spys for protocol. Parsing closures is not supported. Generating methods for parent protocol is not supported.

example:

input:

```swift

protocol Car {

    var name: String? { get }
    var color: Int { get set }

    func go()
    func load(with stuff: Int, label: String) throws -> Int
    func isFull() -> Bool

}

```

output:

```swift
class CarSpy: Car {

    enum CarSpyError: Error {
        case spyError
    }
    typealias ThrowBlock = () throws -> Void

    var name: String?
    var color: Int

    struct Load {
        let stuff: Int
        let label: String
    }

    var goCount = 0
    var load = [Load]()
    var loadThrowBlock: ThrowBlock?
    var loadReturn: Int
    var isFullCount = 0
    var isFullReturn: Bool

    init(color: Int, loadReturn: Int, isFullReturn: Bool) {
        self.color = color
        self.loadReturn = loadReturn
        self.isFullReturn = isFullReturn
    }

    func go() {
        goCount += 1
    }

    func load(with stuff: Int, label: String) throws -> Int {
        let item = Load(stuff: stuff, label: label)
        load.append(item)
        try loadThrowBlock?()
        return loadReturn
    }

    func isFull() -> Bool {
        isFullCount += 1
        return isFullReturn
    }
}
```

usage in tests:
```swift
let carSpy = CarSpy()

...

let a1 = carSpy.goCount == 1
let a2 = carSpy.load.count == 1
let a3 = carSpy.load[0].stuff == 2
let a4 = carSpy.load[0].label == "name"

```

## CLI

Rubicon cli can generate mocks for every protocol in folder. Script runs through every swift file and find every protocol definition. Result is printed at standard out.

example:
```
./rubicon --mocks .
```

### options:

`--mocks path` generates spys for protocols in files.

## Xcode extension

Xcode extension can generate Spy for every or selected `protocol`  in current file. Spy can be written to source file or pasteboard.

