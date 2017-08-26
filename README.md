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
    func load(with staff: Int)
    func isFull() -> Bool

}

```

output:

```swift
class CarSpy: Car {

	var _name: String?
	var name: String? {
		get {
			return _name
		}
	}
	var _color: Int!
	var color: Int {
		get {
			return _color
		}
		set {
			_color = newValue
		}
	}

	var goCount = 0

	struct LoadWith {
		let staff: Int
	}
	var loadWith = [LoadWith]()

	var isFullCount = 0
	var isFullReturn: Bool!

	func go() {
		goCount += 1
	}

	func load(with staff: Int) {
		let item = LoadWith(staff: staff)
		loadWith.append(item)
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
let a2 = carSpy.loadWith.count == 1
let a3 = carSpy.loadWith[0].staff == 2

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

Xcode extension can generate Spy for every `protocol` in current file.

