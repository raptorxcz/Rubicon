@testable import Rubicon
import XCTest

final class DefaultValueGeneratorTests: XCTestCase {
    private var sut: DefaultValueGeneratorImpl!

    override func setUp() {
        super.setUp()
        sut = DefaultValueGeneratorImpl(unknownDefaultType: "default", customDefaultTypes: [:])
    }

    func test_givenUnknownType_whenMakeDefaultValue_thenReturnDefault() {
        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(name: "Unknown")))

        XCTAssertEqual(value, "default")
    }

    func test_givenStringType_whenMakeDefaultValue_thenReturnIdentifier() {
        let value = sut.makeDefaultValue(for: .makeStub(identifier: "name", type: .makeStub(name: "String")))

        XCTAssertEqual(value, "\"name\"")
    }

    func test_givenOptionalType_whenMakeDefaultValue_thenReturnNil() {
        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(composedType: .optional)))

        XCTAssertEqual(value, "nil")
    }

    func test_givenArrayType_whenMakeDefaultValue_thenReturnNil() {
        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(composedType: .array)))

        XCTAssertEqual(value, "[]")
    }

    func test_givenDictionaryType_whenMakeDefaultValue_thenReturnNil() {
        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(composedType: .dictionary)))

        XCTAssertEqual(value, "[:]")
    }

    func test_givenSetType_whenMakeDefaultValue_thenReturnNil() {
        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(composedType: .set)))

        XCTAssertEqual(value, "[]")
    }

    func test_givenIntType_whenMakeDefaultValue_thenReturnZero() {
        let value = sut.makeDefaultValue(for: .makeStub(identifier: "name", type: .makeStub(name: "Int")))

        XCTAssertEqual(value, "0")
    }

    func test_givenBoolType_whenMakeDefaultValue_thenReturnFalse() {
        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(name: "Bool")))

        XCTAssertEqual(value, "false")
    }

    func test_givenCustomDefaultTypeAndCustomType_whenMakeDefaultValue_thenReturnCustomValue() {
        sut = DefaultValueGeneratorImpl(unknownDefaultType: "default", customDefaultTypes: ["A": "b"])

        let value = sut.makeDefaultValue(for: .makeStub(type: .makeStub(name: "A")))

        XCTAssertEqual(value, "b")
    }
}
