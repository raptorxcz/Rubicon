@testable import Rubicon
import XCTest

final class EnumStubGeneratorTests: XCTestCase {
    private var extensionGeneratorSpy: ExtensionGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var indentationGeneratorStub: IndentationGeneratorStub!
    private var sut: EnumStubGeneratorImpl!

    override func setUp() {
        super.setUp()
        extensionGeneratorSpy = ExtensionGeneratorSpy(makeReturn: ["extension"])
        functionGeneratorSpy = FunctionGeneratorSpy(makeCodeReturn: ["function"])
        indentationGeneratorStub = IndentationGeneratorStub()
        sut = EnumStubGeneratorImpl(
            extensionGenerator: extensionGeneratorSpy,
            functionGenerator: functionGeneratorSpy,
            indentationGenerator: IndentationGeneratorStub()
        )
    }

    func test_givenEmptyEnum_whenMakeCode_thenReturnCode() {
        let declaration = EnumDeclaration.makeStub(cases: [])

        let code = sut.generate(from: declaration, functionName: "functionName")

        XCTAssertEqual(code, "extension\n")
        XCTAssertEqual(extensionGeneratorSpy.make.count, 1)
        XCTAssertEqual(extensionGeneratorSpy.make.first?.content, ["function"])
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.name, "functionName")
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.isThrowing, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.isAsync, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.isStatic, true)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.count, 0)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.returnType, .makeStub(name: "EnumName"))
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, ["return "])
    }

    func test_givenVariableEnum_whenMakeCode_thenReturnCode() {
        let declaration = EnumDeclaration.makeStub(cases: [
            "a",
            "b"
        ])

        _ = sut.generate(from: declaration, functionName: "functionName")

        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, ["return .a"])
    }
}

extension EnumDeclaration {
    static func makeStub(
        cases: [String] = []
    ) -> EnumDeclaration {
        return EnumDeclaration(
            name: "EnumName",
            cases: cases,
            notes: [
                "note1",
                "note2"
            ],
            accessLevel: .internal
        )
    }
}
