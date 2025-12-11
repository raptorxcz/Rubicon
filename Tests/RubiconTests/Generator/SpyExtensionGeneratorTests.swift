@testable import Rubicon
import XCTest

final class SpyExtensionGeneratorTests: XCTestCase {
    private var extensionGeneratorSpy: ExtensionGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var functionNameGeneratorSpy: FunctionNameGeneratorSpy!
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var sut: SpyExtensionGenerator!
    private let type = TypeDeclaration.makeStub(name: "Color")

    override func setUp() {
        super.setUp()
        extensionGeneratorSpy = ExtensionGeneratorSpy(makeReturn: ["extension"])
        functionGeneratorSpy = FunctionGeneratorSpy(makeCodeReturn: ["function"])
        functionNameGeneratorSpy = FunctionNameGeneratorSpy(makeUniqueNameReturn: "functionName", makeStructUniqueNameReturn: "StructName")
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "", makeContentAccessLevelReturn: "accessLevel ")
        sut = SpyExtensionGenerator(
            extensionGenerator: extensionGeneratorSpy,
            functionGenerator: functionGeneratorSpy,
            indentationGenerator: IndentationGeneratorStub(),
            functionNameGenerator: functionNameGeneratorSpy,
            accessLevelGenerator: accessLevelGeneratorSpy
        )
    }

    func test_givenEmptyProtocol_whenGenerate_thenGenerateCode() {
        let code = sut.generate(from: .makeStub(), isInitWithOptionalsEnabled: false)

        XCTAssertEqual(code, "extension\n")
        XCTAssertEqual(extensionGeneratorSpy.make.count, 1)
        XCTAssertEqual(extensionGeneratorSpy.make.first?.name, "Name")
        XCTAssertEqual(extensionGeneratorSpy.make.first?.content, ["function"])
        XCTAssertEqual(functionGeneratorSpy.makeCode.count, 1)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.name, "makeSpy")
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.isThrowing, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.isAsync, false)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.isStatic, true)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.count, 0)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.returnType, .makeStub(name: "NameSpy"))
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, [
            "return NameSpy(",
            ")"
        ])
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [
            .makeStub(identifier: "var1", type: .makeStub(name: "t")),
            .makeStub(identifier: "var2")
        ])

        _ = sut.generate(from: protocolDeclaration, isInitWithOptionalsEnabled: false)

        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.count, 2)
        let arguments = functionGeneratorSpy.makeCode.first?.declaration.arguments ?? []
        XCTAssertEqual(arguments[0].name, "var1")
        XCTAssertNil(arguments[0].label)
        XCTAssertNil(arguments[0].defaultValue)
        XCTAssertEqual(arguments[0].type, .makeStub(name: "t"))
        XCTAssertEqual(arguments[1].name, "var2")
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "return NameSpy(",
            "-var1: var1,",
            "-var2: var2",
            ")"
        ])
    }

    func test_givenProtocolWithVariable_andOptionalInitMethods_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [
            .makeStub(identifier: "var1", type: .makeStub(name: "t", composedType: .optional)),
            .makeStub(identifier: "var2")
        ])

        _ = sut.generate(from: protocolDeclaration, isInitWithOptionalsEnabled: true)

        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.count, 2)
        let arguments = functionGeneratorSpy.makeCode.first?.declaration.arguments ?? []
        XCTAssertEqual(arguments[0].name, "var1")
        XCTAssertNil(arguments[0].label)
        XCTAssertEqual(arguments[0].defaultValue, "nil")
        XCTAssertEqual(arguments[0].type, .makeStub(name: "t", composedType: .optional))
        XCTAssertEqual(arguments[1].name, "var2")
        equal(functionGeneratorSpy.makeCode.first?.content, rows: [
            "return NameSpy(",
            "-var1: var1,",
            "-var2: var2",
            ")"
        ])
    }

    func test_givenProtocolWithFunctionWithtReturn_whenGenerate_thenGenerateSpy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(functions: [.makeStub(returnType: .makeStub())])

        _ = sut.generate(from: protocolDeclaration, isInitWithOptionalsEnabled: false)

        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.count, 1)
        let arguments = functionGeneratorSpy.makeCode.first?.declaration.arguments ?? []
        XCTAssertEqual(arguments[0].name, "functionNameReturn")
        XCTAssertNil(arguments[0].label)
        XCTAssertNil(arguments[0].defaultValue)
        XCTAssertEqual(arguments[0].type, .makeStub(name: "Int", composedType: .plain))
    }
}
