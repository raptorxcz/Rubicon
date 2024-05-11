@testable import Rubicon
import XCTest

final class StructStubGeneratorTests: XCTestCase {
    private var extensionGeneratorSpy: ExtensionGeneratorSpy!
    private var functionGeneratorSpy: FunctionGeneratorSpy!
    private var indentationGeneratorStub: IndentationGeneratorStub!
    private var defaultValueGeneratorSpy: DefaultValueGeneratorSpy!
    private var sut: StructStubGeneratorImpl!

    override func setUp() {
        super.setUp()
        extensionGeneratorSpy = ExtensionGeneratorSpy(makeReturn: ["extension"])
        functionGeneratorSpy = FunctionGeneratorSpy(makeCodeReturn: ["function"])
        indentationGeneratorStub = IndentationGeneratorStub()
        defaultValueGeneratorSpy = DefaultValueGeneratorSpy(makeDefaultValueReturn: "default")
        sut = StructStubGeneratorImpl(
            extensionGenerator: extensionGeneratorSpy,
            functionGenerator: functionGeneratorSpy,
            indentationGenerator: IndentationGeneratorStub(),
            defaultValueGenerator: defaultValueGeneratorSpy
        )
    }

    func test_givenEmptyStruct_whenMakeCode_thenReturnCode() {
        let declaration = StructDeclaration.makeStub(variables: [])

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
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.returnType, .makeStub(name: "StructName"))
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, [
            "return StructName()"
        ])
    }

    func test_givenVariableStruct_whenMakeCode_thenReturnCode() {
        let declaration = StructDeclaration.makeStub(variables: [
            .makeStub(),
            .makeStub()
        ])

        let code = sut.generate(from: declaration, functionName: "functionName")

        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.count, 2)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.first?.name, "identifier")
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.first?.label, nil)
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.first?.type, .makeStub())
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.declaration.arguments.first?.defaultValue, "default")
        XCTAssertEqual(functionGeneratorSpy.makeCode.first?.content, [
            "return StructName(",
            "-identifier: identifier,",
            "-identifier: identifier",
            ")"
        ])
    }
}

final class ExtensionGeneratorSpy: ExtensionGenerator {
    struct Make {
        let name: String
        let content: [String]
    }

    var makeReturn: [String]
    var make = [Make]()

    init(makeReturn: [String]) {
        self.makeReturn = makeReturn
    }

    func make(name: String, content: [String]) -> [String] {
        let item = Make(name: name, content: content)
        make.append(item)
        return makeReturn
    }
}

final class DefaultValueGeneratorSpy: DefaultValueGenerator {
    struct MakeDefaultValue {
        let varDeclaration: VarDeclaration
    }

    var makeDefaultValueReturn: String
    var makeDefaultValue = [MakeDefaultValue]()

    init(makeDefaultValueReturn: String) {
        self.makeDefaultValueReturn = makeDefaultValueReturn
    }

    func makeDefaultValue(for varDeclaration: VarDeclaration) -> String {
        let item = MakeDefaultValue(varDeclaration: varDeclaration)
        makeDefaultValue.append(item)
        return makeDefaultValueReturn
    }
}
