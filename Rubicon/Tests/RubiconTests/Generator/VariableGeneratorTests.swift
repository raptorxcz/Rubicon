@testable import Rubicon
import XCTest

final class VariableGeneratorTests: XCTestCase {
    private var typeGeneratorSpy: TypeGeneratorSpy!
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var sut: VariableGeneratorImpl!

    override func setUp() {
        super.setUp()
        typeGeneratorSpy = TypeGeneratorSpy(makeVariableCodeReturn: "Type")
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(
            makeClassAccessLevelReturn: "",
            makeContentAccessLevelReturn: "accessLevel "
        )
        sut = VariableGeneratorImpl(
            typeGenerator: typeGeneratorSpy,
            accessLevelGenerator: accessLevelGeneratorSpy
        )
    }

    func test_whenGenerate_thenGenerateCode() {
        let variableDeclaration = VarDeclaration.makeStub()

        let code = sut.makeStubCode(from: variableDeclaration, getContent: "getContent", setContent: "setContent")

        equal(string: code, rows: [
            "\taccessLevel var identifier: Type {",
            "\tget {",
            "\t\tgetContent",
            "\t}",
            "\tset {",
            "\t\tsetContent",
            "\t}",
            "}",
            ""
        ])
    }

    func test_givenConstant_whenGenerate_thenGenerateCode() {
        let variableDeclaration = VarDeclaration.makeStub(isConstant: true)

        let code = sut.makeStubCode(from: variableDeclaration, getContent: "getContent", setContent: "setContent")

        equal(string: code, rows: [
            "\taccessLevel var identifier: Type {",
            "\tget {",
            "\t\tgetContent",
            "\t}",
            "}",
            ""
        ])
    }
}

final class TypeGeneratorSpy: TypeGenerator {
    struct MakeVariableCode {
        let declaration: TypeDeclaration
    }

    var makeVariableCode = [MakeVariableCode]()
    var makeVariableCodeReturn: String

    init(makeVariableCodeReturn: String) {
        self.makeVariableCodeReturn = makeVariableCodeReturn
    }

    func makeVariableCode(from declaration: TypeDeclaration) -> String {
        let item = MakeVariableCode(declaration: declaration)
        makeVariableCode.append(item)
        return makeVariableCodeReturn
    }
}
