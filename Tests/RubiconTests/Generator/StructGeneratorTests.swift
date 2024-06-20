@testable import Rubicon
import XCTest

final class StructGeneratorTests: XCTestCase {
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var variableGeneratorSpy: VariableGeneratorSpy!
    private var indentationGeneratorStub: IndentationGeneratorStub!
    private var sut: StructGeneratorImpl!

    override func setUp() {
        super.setUp()
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "", makeContentAccessLevelReturn: "accessLevel ")
        variableGeneratorSpy = VariableGeneratorSpy(makeStubCodeReturn: [], makeCodeReturn: "variable")
        indentationGeneratorStub = IndentationGeneratorStub()
        sut = StructGeneratorImpl(
            accessLevelGenerator: accessLevelGeneratorSpy,
            variableGenerator: variableGeneratorSpy,
            indentationGenerator: indentationGeneratorStub
        )
    }

    func test_givenEmptyStruct_whenMakeCode_thenReturnCode() {
        let declaration = StructDeclaration.makeStub()

        let code = sut.makeCode(from: declaration)

        equal(code, rows: [
            "accessLevel struct StructName {",
            "}",
        ])
    }

    func test_givenVariablesStruct_whenMakeCode_thenReturnCode() {
        let declaration = StructDeclaration.makeStub(variables: [.makeStub(), .makeStub()])

        let code = sut.makeCode(from: declaration)

        equal(code, rows: [
            "accessLevel struct StructName {",
            "-variable",
            "-variable",
            "}",
        ])
        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration, .makeStub())
    }


}

extension StructDeclaration {
    static func makeStub(
        variables: [VarDeclaration] = []
    ) -> StructDeclaration {
        return StructDeclaration(
            name: "StructName",
            variables: variables,
            notes: [
                "note1",
                "note2"
            ],
            accessLevel: .internal
        )
    }
}
