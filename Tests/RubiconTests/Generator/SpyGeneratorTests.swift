@testable import Rubicon
import XCTest

final class SpyGeneratorTests: XCTestCase {
    private var protocolGeneratorSpy: ProtocolGeneratorSpy!
    private var variableGeneratorSpy: VariableGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var functionNameGeneratorSpy: FunctionNameGeneratorSpy!
    private var initGeneratorSpy: InitGeneratorSpy!
    private var structGeneratorSpy: StructGeneratorSpy!
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var sut: SpyGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)

    override func setUp() {
        super.setUp()
        protocolGeneratorSpy = ProtocolGeneratorSpy(makeProtocolReturn: ["result"])
        variableGeneratorSpy = VariableGeneratorSpy(makeStubCodeReturn: [], makeCodeReturn: "variable")
        functionGeneratorSpy = FunctionGeneratorSpy(makeCodeReturn: ["function"])
        functionNameGeneratorSpy = FunctionNameGeneratorSpy(makeUniqueNameReturn: "functionName", makeStructUniqueNameReturn: "StructName")
        initGeneratorSpy = InitGeneratorSpy(makeCodeReturn: ["init"])
        structGeneratorSpy = StructGeneratorSpy(makeCodeReturn: ["struct"])
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "", makeContentAccessLevelReturn: "accessLevel ")
        sut = SpyGenerator(
            protocolGenerator: protocolGeneratorSpy,
            variableGenerator: variableGeneratorSpy,
            functionGenerator: functionGeneratorSpy,
            functionNameGenerator: functionNameGeneratorSpy,
            initGenerator: initGeneratorSpy,
            structGenerator: structGeneratorSpy,
            accessLevelGenerator: accessLevelGeneratorSpy
        )
    }

    func test_givenEmptyProtocol_whenGenerate_thenGenerateCode() {
        let result = sut.generate(from: .makeStub())

        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.count, 1)
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.declaration, .makeStub())
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.stub, "Spy")
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "init",
        ])
        XCTAssertEqual(result, "result\n")
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub()])

        _ = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration, .makeStub())
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "",
            "init",
        ])
        XCTAssertEqual(initGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(initGeneratorSpy.makeCode.first?.variables, [.makeStub()])
    }

    func test_givenProtocolWithConstant_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub(isConstant: true)])

        _ = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(initGeneratorSpy.makeCode.first?.variables.first?.isConstant, false)
    }

    func test_givenProtocolWithVariables_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub(), .makeStub()])

        _ = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 2)
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "variable",
            "",
            "init",
        ])
    }

    func test_givenProtocolWithFunctionWithoutReturn_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub()])

        _ = sut.generate(from: protocolDeclaration)

        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "accessLevel var functionNameCount = 0",
            "",
            "init",
            "",
            "function",
        ])
        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 0)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub())
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, ["functionNameCount += 1"])
    }

    func test_givenProtocolWithFunctionWithtReturn_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub(returnType: .makeStub())])

        _ = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.identifier, "functionNameReturn")
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.type, .makeStub())
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.isConstant, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub(returnType: .makeStub()))
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "functionNameCount += 1",
            "return functionNameReturn",
        ])
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "accessLevel var functionNameCount = 0",
            "",
            "init",
            "",
            "function",
        ])
    }

    func test_givenProtocolWithFunctionWithtOptionalReturn_whenGenerate_thenGenerateSpy() {
        let returnType = TypeDeclaration.makeStub(isOptional: true)
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub(returnType: returnType)])

        _ = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.identifier, "functionNameReturn")
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.type, returnType)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.isConstant, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, .makeStub(returnType: returnType))
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, [
            "functionNameCount += 1",
            "return functionNameReturn",
        ])
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "accessLevel var functionNameCount = 0",
            "",
            "init",
            "",
            "function",
        ])
    }

    func test_givenProtocolWithThrowingFunction_whenGenerate_thenGenerateSpy() {
        let returnType = TypeDeclaration.makeStub(isOptional: true)
        let functionDeclaration = FunctionDeclaration.makeStub(isThrowing: true, returnType: returnType)
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [functionDeclaration])

        _ = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(variableGeneratorSpy.makeCode.count, 2)
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.identifier, "functionNameThrowBlock")
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.type, .makeStub(name: "(() throws -> Void)?", isOptional: true, prefix: [.escaping]))
        XCTAssertEqual(variableGeneratorSpy.makeCode.first?.declaration.isConstant, false)
        XCTAssertEqual(variableGeneratorSpy.makeCode.last?.declaration.identifier, "functionNameReturn")
        XCTAssertEqual(variableGeneratorSpy.makeCode.last?.declaration.type, returnType)
        XCTAssertEqual(variableGeneratorSpy.makeCode.last?.declaration.isConstant, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, functionDeclaration)
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "functionNameCount += 1",
            "try functionNameThrowBlock?()",
            "return functionNameReturn",
        ])
        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "variable",
            "variable",
            "accessLevel var functionNameCount = 0",
            "",
            "init",
            "",
            "function",
        ])
    }

    func test_givenProtocolWithFunctionWithArgument_whenGenerate_thenGenerateSpy() {
        let functionDeclaration = FunctionDeclaration.makeStub(arguments: [.makeStub()])
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [functionDeclaration])

        _ = sut.generate(from: protocolDeclaration)

        equal(protocolGeneratorSpy.makeProtocol.first?.content, rows: [
            "struct",
            "",
            "accessLevel var functionName = [StructName]()",
            "",
            "init",
            "",
            "function",
        ])
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration, functionDeclaration)
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "let item = StructName(name: name)",
            "functionName.append(item)",
        ])
        XCTAssertEqual(functionNameGeneratorSpy.makeStructUniqueName.count, 3)
        XCTAssertEqual(functionNameGeneratorSpy.makeStructUniqueName.first?.function, functionDeclaration)
        XCTAssertEqual(structGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(structGeneratorSpy.makeCode.first?.declaration.name, "StructName")
        XCTAssertEqual(structGeneratorSpy.makeCode.first?.declaration.variables.count, 1)
        XCTAssertEqual(structGeneratorSpy.makeCode.first?.declaration.variables.first?.isConstant, true)
        XCTAssertEqual(structGeneratorSpy.makeCode.first?.declaration.variables.first?.identifier, "name")
        XCTAssertEqual(structGeneratorSpy.makeCode.first?.declaration.variables.first?.type, .makeStub())
    }
}

final class StructGeneratorSpy: StructGenerator {
    struct MakeCode {
        let declaration: StructDeclaration
    }

    var makeCode = [MakeCode]()
    var makeCodeReturn: [String]

    init(makeCodeReturn: [String]) {
        self.makeCodeReturn = makeCodeReturn
    }

    func makeCode(from declaration: StructDeclaration) -> [String] {
        let item = MakeCode(declaration: declaration)
        makeCode.append(item)
        return makeCodeReturn
    }
}
