@testable import Rubicon
import XCTest

final class VariableGeneratorTests: XCTestCase {
    private var typeGeneratorSpy: TypeGeneratorSpy!
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var sut: VariableGeneratorImpl!

    override func setUp() {
        super.setUp()
        typeGeneratorSpy = TypeGeneratorSpy(makeVariableCodeReturn: "Type", makeArgumentCodeReturn: "")
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
            "\t\tget {",
            "getContent",
            "\t\t}",
            "\t\tset {",
            "setContent",
            "\t\t}",
            "\t}",
        ])
    }

    func test_givenConstant_whenGenerate_thenGenerateCode() {
        let variableDeclaration = VarDeclaration.makeStub(isConstant: true)

        let code = sut.makeStubCode(from: variableDeclaration, getContent: "getContent", setContent: "setContent")

        equal(string: code, rows: [
            "\taccessLevel var identifier: Type {",
            "\t\tget {",
            "getContent",
            "\t\t}",
            "\t}",
        ])
    }
}

final class TypeGeneratorSpy: TypeGenerator {
    struct MakeVariableCode {
        let declaration: TypeDeclaration
    }

    struct MakeArgumentCode {
        let declaration: TypeDeclaration
    }

    var makeVariableCode = [MakeVariableCode]()
    var makeVariableCodeReturn: String
    var makeArgumentCode = [MakeArgumentCode]()
    var makeArgumentCodeReturn: String

    init(makeVariableCodeReturn: String, makeArgumentCodeReturn: String) {
        self.makeVariableCodeReturn = makeVariableCodeReturn
        self.makeArgumentCodeReturn = makeArgumentCodeReturn
    }

    func makeVariableCode(from declaration: TypeDeclaration) -> String {
        let item = MakeVariableCode(declaration: declaration)
        makeVariableCode.append(item)
        return makeVariableCodeReturn
    }

    func makeArgumentCode(from declaration: TypeDeclaration) -> String {
        let item = MakeArgumentCode(declaration: declaration)
        makeArgumentCode.append(item)
        return makeArgumentCodeReturn
    }
}
