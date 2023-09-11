@testable import Rubicon
import XCTest

final class CreateDummyInteractorTests: XCTestCase {
    private var protocolGeneratorSpy: ProtocolGeneratorSpy!
    private var variableGeneratorSpy: VariableGeneratorSpy!
    private var sut: CreateDummyInteractor!
    private let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)

    override func setUp() {
        super.setUp()
        protocolGeneratorSpy = ProtocolGeneratorSpy(makeProtocolReturn: "result")
        variableGeneratorSpy = VariableGeneratorSpy(makeStubCodeReturn: "variable")
        sut = CreateDummyInteractor(protocolGenerator: protocolGeneratorSpy,variableGenerator: variableGeneratorSpy)
    }

    func test_givenEmptyProtocol_whenGenerate_thenGenerateEmptyDummy() {
        let result = sut.generate(from: .makeStub())

        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.count, 1)
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.declaration, .makeStub())
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.stub, "Dummy")
        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.content, "")
        XCTAssertEqual(result, "result")
    }

    func test_givenProtocolWithVariables_whenGenerate_thenGenerateDummy() {
        let protocolDeclaration = ProtocolDeclaration.makeStub(variables: [.makeStub()])

        let result = sut.generate(from: protocolDeclaration)

        XCTAssertEqual(protocolGeneratorSpy.makeProtocol.first?.content, "variable")
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.count, 1)
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.first?.declaration, .makeStub())
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.first?.getContent, "fatalError()")
        XCTAssertEqual(variableGeneratorSpy.makeStubCode.first?.setContent, "fatalError()")
    }

//    func test_givenProtocolWithVariable_whenGenerate_thenGenerateDummy() {
//        let protocolType = ProtocolDeclaration.makeStub(variables: [.makeStub()])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tvar identifier: Int {",
//            "\t\tget {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t\tset {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithEscapingClosureVariable_whenGenerate_thenGenerateDummy() {
//        let type = TypeDeclaration.makeStub(name: "(() -> Void)", isOptional: false)
//        let variable = VarDeclaration(isConstant: false, identifier: "closeBlock", type: type)
//        let protocolType = ProtocolDeclaration.makeStub(variables: [variable])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tvar closeBlock: (() -> Void) {",
//            "\t\tget {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t\tset {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithConstant_whenGenerate_thenGenerateDummy() {
//        let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)
//        let variable = VarDeclaration(isConstant: true, identifier: "color", type: type)
//        let protocolType = ProtocolDeclaration.makeStub(variables: [variable])
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tvar color: Color {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithOptional_whenGenerate_thenGenerateDummy() {
//        let type = TypeDeclaration.makeStub(name: "Color", isOptional: true)
//        let variable = VarDeclaration(isConstant: true, identifier: "color", type: type)
//        let protocolType = ProtocolDeclaration.makeStub(variables: [variable])
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tvar color: Color? {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithTwoVariables_whenGenerate_thenGenerateDummy() {
//        let variable1 = VarDeclaration(isConstant: false, identifier: "color1", type: type)
//        let variable2 = VarDeclaration(isConstant: false, identifier: "color2", type: type)
//        let protocolType = ProtocolDeclaration.makeStub(variables: [variable1, variable2])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tvar color1: Color {",
//            "\t\tget {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t\tset {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t}",
//            "\tvar color2: Color {",
//            "\t\tget {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t\tset {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithSimpleFunction_whenGenerate_thenGenerateDummy() {
//        let function = FunctionDeclaration.makeStub()
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc name() {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
    ////
//    func test_givenProtocolWithFunctionWithReturn_whenGenerate_thenGenerateDummy() {
//        let function = FunctionDeclaration.makeStub(returnType: .makeStub(name: "Int", isOptional: false))
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc name() -> Int {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithAsyncFunction_whenGenerate_thenGenerateDummy() {
//        let function = FunctionDeclaration.makeStub(isAsync: true)
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc name() async {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithThrowingFunction_whenGenerate_thenGenerateDummy() {
//        let function = FunctionDeclaration.makeStub(isThrowing: true)
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc name() throws {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithThrowingAndAsyncFunction_whenGenerate_thenGenerateDummy() {
//        let function = FunctionDeclaration.makeStub(isThrowing: true, isAsync: true, returnType: .makeStub(name: "Int", isOptional: false))
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc name() async throws -> Int {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithThrowingFunctionWithArguments_whenGenerate_thenGenerateDummy() {
//        let argument = ArgumentDeclaration(label: "with", name: "label", type: type)
//        let function = FunctionDeclaration.makeStub(arguments: [argument], isThrowing: true, returnType: .makeStub(name: "Int", isOptional: false))
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc name(with label: Color) throws -> Int {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithMultipleReturnFunctions_whenGenerate_thenGenerateDummy() {
//        let function = FunctionDeclaration.makeStub(name: "start", returnType: .makeStub(name: "Int", isOptional: false))
//        let function2 = FunctionDeclaration.makeStub(name: "stop", returnType: .makeStub(name: "Int", isOptional: false))
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function, function2])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start() -> Int {",
//            "\t\tfatalError()",
//            "\t}",
//            "",
//            "\tfunc stop() -> Int {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithEscapingType_whenGenerate_thenGenerateDummy() {
//        let argumentType = TypeDeclaration.makeStub(name: "ActionBlock", isOptional: false, prefix: [.escaping])
//        let argument = ArgumentDeclaration(label: "with", name: "action", type: argumentType)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument], returnType: nil)
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(with action: @escaping ActionBlock) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithClosureParameterAndReturnClosure_whenGenerate_thenGenerateDummy() {
//        let argumentType = TypeDeclaration.makeStub(name: "(String) -> Int", isOptional: false, prefix: [.escaping])
//        let argument = ArgumentDeclaration(label: "with", name: "mapping", type: argumentType)
//        let returnType = TypeDeclaration.makeStub(name: "(Data) -> Void", isOptional: false)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument], returnType: returnType)
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(with mapping: @escaping (String) -> Int) -> (Data) -> Void {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithThrowingAutoclosureArgument_whenGenerate_thenGenerateDummy() {
//        let type = TypeDeclaration.makeStub(name: "(Window) throws -> Air", isOptional: false)
//        let function = FunctionDeclaration.makeStub(name: "rollDown", arguments: [], returnType: type)
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc rollDown() -> (Window) throws -> Air {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithClosureAndIntParameterAndOptionalReturnClosure_whenGenerate_thenGenerateDummy() {
//        let closureArgumentType = TypeDeclaration.makeStub(name: "(String) -> Int", isOptional: false, prefix: [.escaping])
//        let closureArgument = ArgumentDeclaration(label: "with", name: "mapping", type: closureArgumentType)
//        let intType = TypeDeclaration.makeStub(name: "Int", isOptional: false)
//        let intArgument = ArgumentDeclaration(label: nil, name: "count", type: intType)
//        let returnType = TypeDeclaration.makeStub(name: "((Data) -> Void)", isOptional: true)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [closureArgument, intArgument], returnType: returnType)
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(with mapping: @escaping (String) -> Int, count: Int) -> ((Data) -> Void)? {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithArgument_whenGenerate_thenGenerateDummy() {
//        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument])
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(a b: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithNoLabelAndArgument_whenGenerate_thenGenerateDummy() {
//        let argument = ArgumentDeclaration(label: "_", name: "b", type: type)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument])
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(_ b: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionWithTwoArguments_whenGenerate_thenGenerateDummy() {
//        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
//        let type2 = TypeDeclaration.makeStub(name: "Color", isOptional: true)
//        let argument2 = ArgumentDeclaration(label: nil, name: "d", type: type2)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument, argument2])
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(a b: Color, d: Color?) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithTwoFunctionWithArgument_whenGenerate_thenGenerateDummy() {
//        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument])
//        let function2 = FunctionDeclaration.makeStub(name: "stop", arguments: [argument])
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function, function2])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(a b: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "",
//            "\tfunc stop(a b: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithFunctionAndVarible_whenGenerate_thenGenerateDummy() {
//        let variable = VarDeclaration(isConstant: false, identifier: "color", type: type)
//        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument])
//        let protocolType = ProtocolDeclaration.makeStub(variables: [variable], functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tvar color: Color {",
//            "\t\tget {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t\tset {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t}",
//            "",
//            "\tfunc start(a b: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithLongNames_whenGenerate_thenDummyIsGenerated() {
//        let argument = ArgumentDeclaration(label: nil, name: "productId", type: type)
//        let function = FunctionDeclaration.makeStub(name: "startGenerating", arguments: [argument])
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc startGenerating(productId: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithSameFunctionNames_whenGenerate_thenGenerateDummy() {
//        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
//        let argument2 = ArgumentDeclaration(label: "c", name: "d", type: type)
//        let function = FunctionDeclaration.makeStub(name: "start", arguments: [argument])
//        let function2 = FunctionDeclaration.makeStub(name: "start", arguments: [argument2])
//        let protocolType = ProtocolDeclaration.makeStub(functions: [function, function2])
//
//        equal(protocolType: protocolType, rows: [
//            "final class NameDummy: Name {",
//            "",
//            "\tfunc start(a b: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "",
//            "\tfunc start(c d: Color) {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithNoArgumentLabelAndReturnValue_whenGenerate_thenGenerateDummy() {
//        let argumentType = TypeDeclaration.makeStub(name: "Int", isOptional: true)
//        let argument = ArgumentDeclaration(label: "_", name: "value", type: argumentType)
//        let returnType = TypeDeclaration.makeStub(name: "String", isOptional: true)
//        let function = FunctionDeclaration.makeStub(name: "formattedString", arguments: [argument], returnType: returnType)
//        let protocolType = ProtocolDeclaration(name: "Formatter", parents: [], variables: [], functions: [function])
//
//        equal(protocolType: protocolType, rows: [
//            "final class FormatterDummy: Formatter {",
//            "",
//            "\tfunc formattedString(_ value: Int?) -> String? {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenEmptyProtocolAndPrivate_whenGenerate_thenGenerateDummy() {
//        let protocolType = ProtocolDeclaration(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])
//
//        equal(protocolType: protocolType, accessLevel: .private, rows: [
//            "private final class TestTestTestTestTestDummy: TestTestTestTestTest {",
//            "}",
//            "",
//        ])
//    }
//
//    func test_givenProtocolWithArgumentAndThrowingFunctionWithReturnValue_whenGeneratePublic_thenGenerateDummy() {
//        let variable = VarDeclaration(isConstant: false, identifier: "color", type: type)
//        let variable2 = VarDeclaration(isConstant: true, identifier: "color", type: type)
//        let argumentType = TypeDeclaration.makeStub(name: "Int", isOptional: true)
//        let argument = ArgumentDeclaration(label: "_", name: "value", type: argumentType)
//        let returnType = TypeDeclaration.makeStub(name: "String", isOptional: true)
//        let function = FunctionDeclaration.makeStub(name: "formattedString", arguments: [argument], isThrowing: true, returnType: returnType)
//        let protocolType = ProtocolDeclaration(name: "Formatter", parents: [], variables: [variable, variable2], functions: [function])
//
//        equal(protocolType: protocolType, accessLevel: .public, rows: [
//            "public final class FormatterDummy: Formatter {",
//            "",
//            "\tpublic var color: Color {",
//            "\t\tget {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t\tset {",
//            "\t\t\tfatalError()",
//            "\t\t}",
//            "\t}",
//            "\tpublic var color: Color {",
//            "\t\tfatalError()",
//            "\t}",
//            "",
//            "\tpublic init() {",
//            "\t}",
//            "",
//            "\tpublic func formattedString(_ value: Int?) throws -> String? {",
//            "\t\tfatalError()",
//            "\t}",
//            "}",
//            "",
//        ])
//    }
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
        let content: String
    }

    var makeProtocol = [MakeProtocol]()
    var makeProtocolReturn: String

    init(makeProtocolReturn: String) {
        self.makeProtocolReturn = makeProtocolReturn
    }

    func makeProtocol(from declaration: ProtocolDeclaration, stub: String, content: String) -> String {
        let item = MakeProtocol(declaration: declaration, stub: stub, content: content)
        makeProtocol.append(item)
        return makeProtocolReturn
    }
}

final class VariableGeneratorSpy: VariableGenerator {

    struct MakeStubCode {
        let declaration: VarDeclaration
        let getContent: String
        let setContent: String
    }

    var makeStubCode = [MakeStubCode]()
    var makeStubCodeReturn: String

    init(makeStubCodeReturn: String) {
        self.makeStubCodeReturn = makeStubCodeReturn
    }

    func makeStubCode(from declaration: VarDeclaration, getContent: String, setContent: String) -> String {
        let item = MakeStubCode(declaration: declaration, getContent: getContent, setContent: setContent)
        makeStubCode.append(item)
        return makeStubCodeReturn
    }
}
