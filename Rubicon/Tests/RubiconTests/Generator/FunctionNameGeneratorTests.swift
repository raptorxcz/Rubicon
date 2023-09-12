@testable import Rubicon
import XCTest

final class FunctionNameGeneratorTests: XCTestCase {
    private var sut: FunctionNameGeneratorImpl!

    override func setUp() {
        super.setUp()
        sut = FunctionNameGeneratorImpl()
    }

    func test_givenSingleFunction_whenMakeUniqueName_thenReturnShortName() {
        let function = FunctionDeclaration.makeStub(arguments: [.makeStub()])

        let name = sut.makeUniqueName(for: function, in: [function])

        XCTAssertEqual(name, "name")
    }

    func test_givenMultipleFunctionsWithSameNameAndNilLabel_whenMakeUniqueName_thenReturnLongName() {
        let otherFunction = FunctionDeclaration.makeStub(arguments: [.makeStub()])
        let function = FunctionDeclaration.makeStub(arguments: [.makeStub(label: nil, name: "other")])

        let name = sut.makeUniqueName(for: function, in: [function, otherFunction])

        XCTAssertEqual(name, "nameOther")
    }

    func test_givenMultipleFunctionsWithSameNameAndLabelUnderscope_whenMakeUniqueName_thenReturnLongName() {
        let otherFunction = FunctionDeclaration.makeStub(arguments: [.makeStub()])
        let function = FunctionDeclaration.makeStub(arguments: [.makeStub(label: "_", name: "other")])

        let name = sut.makeUniqueName(for: function, in: [function, otherFunction])

        XCTAssertEqual(name, "nameOther")
    }

    func test_givenMultipleFunctionsWithSameNameAndNameUnderscope_whenMakeUniqueName_thenReturnLongName() {
        let otherFunction = FunctionDeclaration.makeStub(arguments: [.makeStub()])
        let function = FunctionDeclaration.makeStub(arguments: [.makeStub(label: "label", name: "_")])

        let name = sut.makeUniqueName(for: function, in: [function, otherFunction])

        XCTAssertEqual(name, "nameLabel")
    }

    func test_givenMultipleFunctionsWithSameNameAndLabel_whenMakeUniqueName_thenReturnLongName() {
        let otherFunction = FunctionDeclaration.makeStub(arguments: [.makeStub()])
        let function = FunctionDeclaration.makeStub(arguments: [.makeStub(label: "label", name: "attribute")])

        let name = sut.makeUniqueName(for: function, in: [function, otherFunction])

        XCTAssertEqual(name, "nameLabelAttribute")
    }
}
