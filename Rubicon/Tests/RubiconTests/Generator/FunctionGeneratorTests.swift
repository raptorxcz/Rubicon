@testable import Rubicon
import XCTest

final class FunctionGeneratorTests: XCTestCase {
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var typeGeneratorSpy: TypeGeneratorSpy!
    private var argumentGeneratorSpy: ArgumentGeneratorSpy!
    private var sut: FunctionGeneratorImpl!

    override func setUp() {
        super.setUp()
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "", makeContentAccessLevelReturn: "accessLevel ")
        typeGeneratorSpy = TypeGeneratorSpy(makeVariableCodeReturn: "Type", makeArgumentCodeReturn: "")
        argumentGeneratorSpy = ArgumentGeneratorSpy(makeCodeReturn: "argument")
        sut = FunctionGeneratorImpl(
            accessLevelGenerator: accessLevelGeneratorSpy,
            typeGenerator: typeGeneratorSpy,
            argumentGenerator: argumentGeneratorSpy
        )
    }

    func test_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub()

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name() {",
            "content",
            "\t}",
        ])
        XCTAssertEqual(accessLevelGeneratorSpy.makeContentAccessLevelCount, 1)
    }

    func test_givenThrow_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub(isThrowing: true)

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name() throws {",
            "content",
            "\t}",
        ])
    }

    func test_givenAsync_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub(isAsync: true)

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name() async {",
            "content",
            "\t}",
        ])
    }

    func test_givenThrowAndAsync_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub(isThrowing: true, isAsync: true)

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name() async throws {",
            "content",
            "\t}",
        ])
    }

    func test_givenThrowAndAsyncAndResult_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub(isThrowing: true, isAsync: true, returnType: .makeStub())

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name() async throws -> Type {",
            "content",
            "\t}",
        ])
    }

    func test_givenArgument_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub(arguments: [.makeStub()])

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name(argument) {",
            "content",
            "\t}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(argumentGeneratorSpy.makeCode.first?.declaration, .makeStub())
    }

    func test_givenArguments_whenGenerate_thenGenerateCode() {
        let declaration = FunctionDeclaration.makeStub(arguments: [.makeStub(), .makeStub(label: "a", name: "b", type: .makeStub())])

        let code = sut.makeCode(from: declaration, content: "content")

        equal(string: code, rows: [
            "\taccessLevel func name(argument, argument) {",
            "content",
            "\t}",
        ])
        XCTAssertEqual(argumentGeneratorSpy.makeCode.count, 2)
    }
}

final class ArgumentGeneratorSpy: ArgumentGenerator {

    struct MakeCode {
        let declaration: ArgumentDeclaration
    }

    var makeCode = [MakeCode]()
    var makeCodeReturn: String

    init(makeCodeReturn: String) {
        self.makeCodeReturn = makeCodeReturn
    }

    func makeCode(from declaration: ArgumentDeclaration) -> String {
        let item = MakeCode(declaration: declaration)
        makeCode.append(item)
        return makeCodeReturn
    }
}
