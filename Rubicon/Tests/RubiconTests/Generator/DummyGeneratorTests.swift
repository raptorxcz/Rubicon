@testable import Rubicon
import XCTest

final class DummyGeneratorTests: XCTestCase {
    private var protocolGeneratorSpy: ProtocolGeneratorSpy!
    private var variableGeneratorSpy: VariableGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var initGeneratorSpy: InitGeneratorSpy!
    private var sut: DummyGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)

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
        isOptional: Bool = false,
        prefix: [Prefix] = []
    ) -> TypeDeclaration {
        return TypeDeclaration(
            name: name,
            isOptional: isOptional,
            prefix: prefix
        )
    }
}

extension ProtocolDeclaration {
    static func makeStub(
        variables: [VarDeclaration] = [],
        functions: [FunctionDeclaration] = []
    ) -> ProtocolDeclaration {
        return ProtocolDeclaration(
            name: "Name",
            parents: [],
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
    }

    var makeCode = [MakeCode]()
    var makeCodeReturn: [String]

    init(makeCodeReturn: [String]) {
        self.makeCodeReturn = makeCodeReturn
    }

    func makeCode(from declaration: FunctionDeclaration, content: [String]) -> [String] {
        let item = MakeCode(declaration: declaration, content: content)
        makeCode.append(item)
        return makeCodeReturn
    }
}