@testable import Rubicon
import XCTest

final class InitGeneratorTests: XCTestCase {
    private var argumentGeneratorSpy: ArgumentGeneratorSpy!
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var indentationGeneratorStub: IndentationGeneratorStub!
    private var sut: InitGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color")

    override func setUp() {
        super.setUp()
        initialize(accessLevel: .internal)
    }

    func initialize(accessLevel: AccessLevel) {
        argumentGeneratorSpy = ArgumentGeneratorSpy(makeCodeReturn: "argument")
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "", makeContentAccessLevelReturn: "accessLevel ")
        indentationGeneratorStub = IndentationGeneratorStub()
        sut = InitGeneratorImpl(
            accessLevel: accessLevel,
            accessLevelGenerator: accessLevelGeneratorSpy,
            indentationGenerator: indentationGeneratorStub,
            argumentGenerator: argumentGeneratorSpy
        )
    }

    func test_givenNoVariable_whenMakeCode_thenDoNotMakeInit() {
        let result = sut.makeCode(with: [], isAddingDefaultValueToOptionalsEnabled: false)

        XCTAssertEqual(result, [])
    }

    func test_givenPublicAccessLevelAndNoVariable_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(with: [], isAddingDefaultValueToOptionalsEnabled: false)

        equal(result, rows: [
            "accessLevel init() {",
            "}",
        ])
    }

    func test_givenSomeVariables_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(with: [.makeStub(), .makeStub()], isAddingDefaultValueToOptionalsEnabled: false)

        equal(result, rows: [
            "accessLevel init(argument, argument) {",
            "-self.identifier = identifier",
            "-self.identifier = identifier",
            "}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub()))
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub()))
    }

    func test_givenOptionalVariable_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(
            with: [
                .makeStub(type: .makeStub(prefix: [.escaping])),
                .makeStub(type: .makeStub(prefix: [.escaping], composedType: .optional))
            ],
            isAddingDefaultValueToOptionalsEnabled: false
        )

        equal(result, rows: [
            "accessLevel init(argument, argument) {",
            "-self.identifier = identifier",
            "-self.identifier = identifier",
            "}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub(prefix: [.escaping])))
        XCTAssertEqual(argumentGeneratorSpy.makeCode.last?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub(prefix: [], composedType: .optional)))
    }

    func test_givenOptionalVariableAndIsAddingDefaultValueToOptionalsEnabled_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(
            with: [.makeStub(), .makeStub(type: .makeStub(composedType: .optional))],
            isAddingDefaultValueToOptionalsEnabled: true
        )

        equal(result, rows: [
            "accessLevel init(argument, argument) {",
            "-self.identifier = identifier",
            "-self.identifier = identifier",
            "}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub()))
    }
}
