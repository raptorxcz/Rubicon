@testable import Rubicon
import XCTest

final class StubGeneratorTests: XCTestCase {
    private var protocolGeneratorSpy: ProtocolGeneratorSpy!
    private var variableGeneratorSpy: VariableGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var functionNameGeneratorSpy: FunctionNameGeneratorSpy!
    private var initGeneratorSpy: InitGeneratorSpy!
    private var sut: StubGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color")

    override func setUp() {
        super.setUp()
        protocolGeneratorSpy = ProtocolGeneratorSpy(makeProtocolReturn: ["result"])
        variableGeneratorSpy = VariableGeneratorSpy(makeStubCodeReturn: [], makeCodeReturn: "variable")
        functionGeneratorSpy = FunctionGeneratorSpy(makeCodeReturn: ["function"])
        functionNameGeneratorSpy = FunctionNameGeneratorSpy(makeUniqueNameReturn: "functionName", makeStructUniqueNameReturn: "")
        initGeneratorSpy = InitGeneratorSpy(makeCodeReturn: ["init"])
        sut = StubGenerator(
            protocolGenerator: protocolGeneratorSpy,
            variableGenerator: variableGeneratorSpy,
            functionGenerator: functionGeneratorSpy,
            functionNameGenerator: functionNameGeneratorSpy,
            initGenerator: initGeneratorSpy
        )
    }

    func test_givenEmptyProtocol_whenGenerate_thenGenerateCode() {
        let result = sut.generate(from: .makeStub(), nameSuffix: "Suffix", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.count, 1)
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.declaration, .makeStub())
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.stub, "Suffix")
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "init",
        ])
        XCTAssertEqual(result, "result\n")
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateStub() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub()])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration, .makeStub())
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "",
            "init",
        ])
        XCTAssertEqual(initGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(initGeneratorSpy.makeCode.first?.variables, [.makeStub()])
        XCTAssertEqual(initGeneratorSpy.makeCode.first?.isAddingDefaultValueToOptionalsEnabled, false)
    }

    func test_givenProtocolWithConstant_whenGenerate_thenGenerateStub() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub(isConstant: true)])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(initGeneratorSpy.makeCode.first?.variables.first?.isConstant, false)
    }

    func test_givenProtocolWithVariables_whenGenerate_thenGenerateStub() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub(), .makeStub()])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 2)
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "variable",
            "",
            "init",
        ])
    }

    func test_givenProtocolWithFunctionWithoutReturn_whenGenerate_thenGenerateStub() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub()])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "init",
            "",
            "function",
        ])
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub())
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, [])
    }

    func test_givenProtocolWithFunctionWithtReturn_whenGenerate_thenGenerateStub() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub(returnType: .makeStub())])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.identifier, "functionNameReturn")
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.type, .makeStub())
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.isConstant, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub(returnType: .makeStub()))
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "return functionNameReturn",
        ])
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "",
            "init",
            "",
            "function",
        ])
    }

    func test_givenProtocolWithFunctionWithtOptionalReturn_whenGenerate_thenGenerateStub() {
        let returnType = TypeDeclaration.makeStub(composedType: .optional)
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub(returnType: returnType)])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.identifier, "functionNameReturn")
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.type, returnType)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.isConstant, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub(returnType: returnType))
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, ["return functionNameReturn"])
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "",
            "init",
            "",
            "function",
        ])
    }

    func test_givenProtocolWithThrowingFunction_whenGenerate_thenGenerateStub() {
        let returnType = TypeDeclaration.makeStub(composedType: .optional)
        let functionDeclaration = FunctionDeclaration.makeStub(isThrowing: true, returnType: returnType)
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [functionDeclaration])

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: false)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.identifier, "functionNameThrowBlock")
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.type, .makeStub(name: "(() throws -> Void)?", prefix: [.escaping], composedType: .optional))
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.isConstant, false)
        XCTAssertEqual(variableGeneratorSpy.makeCode.last?.declaration.identifier, "functionNameReturn")
        XCTAssertEqual(variableGeneratorSpy.makeCode.last?.declaration.type, returnType)
        XCTAssertEqual(variableGeneratorSpy.makeCode.last?.declaration.isConstant, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, functionDeclaration)
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "try functionNameThrowBlock?()",
            "return functionNameReturn",
        ])
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "variable",
            "",
            "init",
            "",
            "function",
        ])
    }

    func test_givenProtocolWithOptionalVariablesAndIsInitWithOptionalsEnabled_whenGenerate_thenGenerateSpyWithMultipleInits() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(
            variables: [
                .makeStub(),
                .makeStub(type: .makeStub(composedType: .optional))
            ]
        )

        _ = sut.generate(from: protocolDeclaration, nameSuffix: "Stub", isInitWithOptionalsEnabled: true)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 2)
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "variable",
            "",
            "init",
        ])
        XCTAssertEqual(initGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(initGeneratorSpy.makeCode[0].variables.count, 2)
    }
}

final class FunctionNameGeneratorSpy: FunctionNameGenerator {
    struct MakeUniqueName {
        let function: FunctionDeclaration
        let functions: [FunctionDeclaration]
    }

    struct MakeStructUniqueName {
        let function: FunctionDeclaration
        let functions: [FunctionDeclaration]
    }

    var makeUniqueName = [MakeUniqueName]()
    var makeUniqueNameReturn: String
    var makeStructUniqueName = [MakeStructUniqueName]()
    var makeStructUniqueNameReturn: String

    init(makeUniqueNameReturn: String, makeStructUniqueNameReturn: String) {
        self.makeUniqueNameReturn = makeUniqueNameReturn
        self.makeStructUniqueNameReturn = makeStructUniqueNameReturn
    }

    func makeUniqueName(for function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> String {
        let item = MakeUniqueName(function: function, functions: functions)
        makeUniqueName.append(item)
        return makeUniqueNameReturn
    }

    func makeStructUniqueName(for function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> String {
        let item = MakeStructUniqueName(function: function, functions: functions)
        makeStructUniqueName.append(item)
        return makeStructUniqueNameReturn
    }
}

final class InitGeneratorSpy: InitGenerator {
    struct MakeCode {
        let variables: [VarDeclaration]
        let isAddingDefaultValueToOptionalsEnabled: Bool
    }

    var makeCodeReturn: [String]
    var makeCode = [MakeCode]()

    init(makeCodeReturn: [String]) {
        self.makeCodeReturn = makeCodeReturn
    }

    func makeCode(with variables: [VarDeclaration], isAddingDefaultValueToOptionalsEnabled: Bool) -> [String] {
        let item = MakeCode(variables: variables, isAddingDefaultValueToOptionalsEnabled: isAddingDefaultValueToOptionalsEnabled)
        makeCode.append(item)
        return makeCodeReturn
    }
}
