@testable import Rubicon
import XCTest

final class InitGeneratorTests: XCTestCase {
    private var argumentGeneratorSpy: ArgumentGeneratorSpy!
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var indentationGeneratorStub: IndentationGeneratorStub!
    private var sut: InitGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)

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
        let result = sut.makeCode(with: [])

        XCTAssertEqual(result, [])
    }

    func test_givenPublicAccessLevelAndNoVariable_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(with: [])

        equal(result, rows: [
            "accessLevel init() {",
            "}",
        ])
    }

    func test_givenSomeVariables_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(with: [.makeStub(), .makeStub()])

        equal(result, rows: [
            "accessLevel init(argument, argument) {",
            "-self.identifier = identifier",
            "-self.identifier = identifier",
            "}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub()))
    }

    func test_givenOptionalVariable_whenMakeCode_thenMakeInit() {
        initialize(accessLevel: .public)

        let result = sut.makeCode(with: [.makeStub(), .makeStub(type: .makeStub(isOptional: true))])

        equal(result, rows: [
            "accessLevel init(argument) {",
            "-self.identifier = identifier",
            "}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub(label: nil, name: "identifier", type: .makeStub()))
    }
}
