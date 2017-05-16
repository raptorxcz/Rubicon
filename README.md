# Rubicon
[![Build Status](https://travis-ci.org/raptorxcz/Rubicon.svg?branch=master)](https://travis-ci.org/raptorxcz/Rubicon)
[![Build Status](https://codecov.io/gh/raptorxcz/Rubicon/branch/master/graph/badge.svg)](https://codecov.io/gh/raptorxcz/Rubicon)

Swift parser + mock generator

Rubicon generates spys for protocol. Parsing closures is not supported. Generating methord for parent protocol is not supported.

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

	var name: String!
	var color: Int!

	var goCount = 0

	var loadWithCount = 0
	var loadWithStaff: Int?

	var isFullCount = 0
	var isFullReturn: Bool!

	func go() {
		goCount += 1
	}

	func load(with staff: Int) {
		loadWithCount += 1
		loadWithStaff = staff
	}

	func isFull() -> Bool {
		isFullCount += 1
		return isFullReturn
	}

}
```

##CLI

Rubicon cli can generate mocks for every protocol in folder. Script runs through every swift file and find every protocol definition. Result is printed at standard out.

example:
```
./rubicon --mocks .
```

###options:

`--mocks path` generates spys for protocols in files.

##Xcode extension

Xcode extension can generate Spy for every `protocol` in current file.

