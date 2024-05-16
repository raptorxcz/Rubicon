@testable import Rubicon
import XCTest

final class DummyGeneratorTests: XCTestCase {
    private var protocolGeneratorSpy: ProtocolGeneratorSpy!
    private var variableGeneratorSpy: VariableGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var initGeneratorSpy: InitGeneratorSpy!
    private var sut: DummyGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color")

    override func setUp() {
        super.setUp()
        protocolGeneratorSpy = ProtocolGeneratorSpy(makeProtocolReturn: ["result"])
        variableGeneratorSpy = VariableGeneratorSpy(makeStubCodeReturn: ["variable"], makeCodeReturn: "")
        functionGeneratorSpy = FunctionGeneratorSpy(makeCodeReturn: ["function"])
        initGeneratorSpy = InitGeneratorSpy(makeCodeReturn: ["init"])
        sut = DummyGenerator(
            protocolGenerator: protocolGeneratorSpy,
            variableGenerator: variableGeneratorSpy,
            functionGenerator: functionGeneratorSpy,
            initGenerator: initGeneratorSpy
        )
    }

    func test_givenEmptyProtocol_whenGenerate_thenGenerateCode() {
        let result = sut.generate(from: .makeStub())

        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.count, 1)
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.declaration, .makeStub())
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.stub, "Dummy")
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "init",
        ])
        XCTAssertEqual(result, "result\n")
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateDummy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub()])

        _ = sut.generate(from: protocolDeclaration)

        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "",
            "init",
        ])
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.first?.declaration, .makeStub())
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.first?.getContent, ["fatalError()"])
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.first?.setContent, ["fatalError()"])
    }

    func test_givenProtocolWithVariables_whenGenerate_thenGenerateDummy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub(), .makeStub()])

        _ = sut.generate(from: protocolDeclaration)

        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "variable",
            "",
            "init",
        ])
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.count, 2)
    }

    func test_givenProtocolWithFunction_whenGenerate_thenGenerateDummy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub()])

        _ = sut.generate(from: protocolDeclaration)

        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "init",
            "",
            "function",
        ])
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub())
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, ["fatalError()"])
    }
}

extension TypeDeclaration {
    static func makeStub(
        name: String = "Int",
        prefix: [Prefix] = [],
        composedType: ComposedType = .plain
    ) -> TypeDeclaration {
        return TypeDeclaration(
            name: name,
            prefix: prefix,
            composedType: composedType
        )
    }
}

extension ProtocolDeclaration {
    static func makeStub(
        parents: [String] = [],
        variables: [VarDeclaration] = [],
        functions: [FunctionDeclaration] = []
    ) -> ProtocolDeclaration {
        return ProtocolDeclaration(
            name: "Name",
            parents: parents,
            variables: variables,
            functions: functions
        )
    }
}

final class ProtocolGeneratorSpy: ProtocolGenerator {
    struct MakeProtocol {
        let declaration: ProtocolDeclaration
        let stub: String
        let content: [String]
    }

    var makeProtocol = [MakeProtocol]()
    var makeProtocolReturn: [String]

    init(makeProtocolReturn: [String]) {
        self.makeProtocolReturn = makeProtocolReturn
    }

    func makeProtocol(from declaration: ProtocolDeclaration, stub: String, content: [String]) -> [String] {
        let item = MakeProtocol(declaration: declaration, stub: stub, content: content)
        makeProtocol.append(item)
        return makeProtocolReturn
    }
}

final class VariableGeneratorSpy: VariableGenerator {
    struct MakeStubCode {
        let declaration: VarDeclaration
        let getContent: [String]
        let setContent: [String]
    }

    struct MakeCode {
        let declaration: VarDeclaration
    }

    var makeStubCode = [MakeStubCode]()
    var makeStubCodeReturn: [String]
    var makeCode = [MakeCode]()
    var makeCodeReturn: String

    init(makeStubCodeReturn: [String], makeCodeReturn: String) {
        self.makeStubCodeReturn = makeStubCodeReturn
        self.makeCodeReturn = makeCodeReturn
    }

    func makeStubCode(from declaration: VarDeclaration, getContent: [String], setContent: [String]) -> [String] {
        let item = MakeStubCode(declaration: declaration, getContent: getContent, setContent: setContent)
        makeStubCode.append(item)
        return makeStubCodeReturn
    }

    func makeCode(from declaration: VarDeclaration) -> String {
        let item = MakeCode(declaration: declaration)
        makeCode.append(item)
        return makeCodeReturn
    }
}

final class FunctionGeneratorSpy: FunctionGenerator {
    struct MakeCode {
        let declaration: FunctionDeclaration
        let content: [String]
        let isEachArgumentOnNewLineEnabled: Bool
    }

    var makeCodeReturn: [String]
    var makeCode = [MakeCode]()

    init(makeCodeReturn: [String]) {
        self.makeCodeReturn = makeCodeReturn
    }

    func makeCode(from declaration: FunctionDeclaration, content: [String], isEachArgumentOnNewLineEnabled: Bool) -> [String] {
        let item = MakeCode(declaration: declaration, content: content, isEachArgumentOnNewLineEnabled: isEachArgumentOnNewLineEnabled)
        makeCode.append(item)
        return makeCodeReturn
    }
}
