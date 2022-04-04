//
//  CreateStubInteractorTests.swift
//  GeneratorTests
//
//  Created by Kryštof Matěj on 16/02/2019.
//  Copyright © 2019 Kryštof Matěj. All rights reserved.
//

import Generator
import XCTest

class CreateStubInteractorTests: XCTestCase {
    private var generator: CreateStubInteractor!
    private let type = Type(name: "Color", isOptional: false)

    func test_givenprotocolType_whenGenerate_thenGenerateEmptyStub() {
        let protocolType = ProtocolType(name: "Test", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "class TestStub: Test {",
            "}",
            "",
        ])
    }

    func test_givenprotocolTypeWithLongName_whenGenerate_thenGenerateEmptyStub() {
        let protocolType = ProtocolType(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "class TestTestTestTestTestStub: TestTestTestTestTest {",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateStub() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar color: Color",
            "",
            "\tinit(color: Color) {",
            "\t\tself.color = color",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithEscapingClosureVariable_whenGenerate_thenGenerateStub() {
        let type = Type(name: "(() -> Void)", isOptional: false, isClosure: true)
        let variable = VarDeclarationType(isConstant: false, identifier: "closeBlock", type: type)
        let protocolType = ProtocolType(name: "Door", parents: [], variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class DoorStub: Door {",
            "",
            "\tvar closeBlock: (() -> Void)",
            "",
            "\tinit(closeBlock: @escaping (() -> Void)) {",
            "\t\tself.closeBlock = closeBlock",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithConstant_whenGenerate_thenGenerateStub() {
        let type = Type(name: "Color", isOptional: false)
        let variable = VarDeclarationType(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar color: Color",
            "",
            "\tinit(color: Color) {",
            "\t\tself.color = color",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithOptional_whenGenerate_thenGenerateStub() {
        let type = Type(name: "Color", isOptional: true)
        let variable = VarDeclarationType(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar color: Color?",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithTwoVariables_whenGenerate_thenGenerateStub() {
        let variable1 = VarDeclarationType(isConstant: false, identifier: "color1", type: type)
        let variable2 = VarDeclarationType(isConstant: false, identifier: "color2", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable1, variable2], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar color1: Color",
            "\tvar color2: Color",
            "",
            "\tinit(color1: Color, color2: Color) {",
            "\t\tself.color1 = color1",
            "\t\tself.color2 = color2",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithSimpleFunction_whenGenerate_thenGenerateStub() {
        let function = FunctionDeclarationType(name: "start")
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start() {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithReturn_whenGenerate_thenGenerateStub() {
        let function = FunctionDeclarationType(name: "start", returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start() -> Int {",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithAsyncFunction_whenGenerate_thenGenerateStub() {
        let function = FunctionDeclarationType(name: "start", isAsync: true, returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start() async -> Int {",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithThrowingFunction_whenGenerate_thenGenerateStub() {
        let function = FunctionDeclarationType(name: "start", isThrowing: true, returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tenum StubError: Error {",
            "\t\tcase stubError",
            "\t}",
            "\ttypealias ThrowBlock = () throws -> Void",
            "",
            "\tvar startThrowBlock: ThrowBlock?",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start() throws -> Int {",
            "\t\ttry startThrowBlock?()",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithThrowingAndAsyncFunction_whenGenerate_thenGenerateStub() {
        let function = FunctionDeclarationType(name: "start", isThrowing: true, isAsync: true, returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tenum StubError: Error {",
            "\t\tcase stubError",
            "\t}",
            "\ttypealias ThrowBlock = () throws -> Void",
            "",
            "\tvar startThrowBlock: ThrowBlock?",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start() async throws -> Int {",
            "\t\ttry startThrowBlock?()",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithThrowingFunctionWithArguments_whenGenerate_thenGenerateStub() {
        let argument = ArgumentType(label: "with", name: "label", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument], isThrowing: true, returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tenum StubError: Error {",
            "\t\tcase stubError",
            "\t}",
            "\ttypealias ThrowBlock = () throws -> Void",
            "",
            "\tvar startThrowBlock: ThrowBlock?",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start(with label: Color) throws -> Int {",
            "\t\ttry startThrowBlock?()",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithMultipleReturnFunctions_whenGenerate_thenGenerateStub() {
        let function = FunctionDeclarationType(name: "start", returnType: Type(name: "Int", isOptional: false))
        let function2 = FunctionDeclarationType(name: "stop", returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar startReturn: Int",
            "\tvar stopReturn: Int",
            "",
            "\tinit(startReturn: Int, stopReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t\tself.stopReturn = stopReturn",
            "\t}",
            "",
            "\tfunc start() -> Int {",
            "\t\treturn startReturn",
            "\t}",
            "",
            "\tfunc stop() -> Int {",
            "\t\treturn stopReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithEscapingType_whenGenerate_thenGenerateStub() {
        let argumentType = Type(name: "ActionBlock", isOptional: false, isClosure: true, prefix: .escaping)
        let argument = ArgumentType(label: "with", name: "action", type: argumentType)
        let function = FunctionDeclarationType(name: "start", arguments: [argument], returnType: nil)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start(with action: @escaping ActionBlock) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithClosureParameterAndReturnClosure_whenGenerate_thenGenerateStub() {
        let argumentType = Type(name: "(String) -> Int", isOptional: false, isClosure: true, prefix: .escaping)
        let argument = ArgumentType(label: "with", name: "mapping", type: argumentType)
        let returnType = Type(name: "(Data) -> Void", isOptional: false, isClosure: true)
        let function = FunctionDeclarationType(name: "start", arguments: [argument], returnType: returnType)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar startReturn: (Data) -> Void",
            "",
            "\tinit(startReturn: @escaping (Data) -> Void) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start(with mapping: @escaping (String) -> Int) -> (Data) -> Void {",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithThrowingAutoclosureArgument_whenGenerate_thenGenerateStub() {
        let type = Type(name: "(Window) throws -> Air", isOptional: false, isClosure: true)
        let function = FunctionDeclarationType(name: "rollDown", arguments: [], returnType: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar rollDownReturn: (Window) throws -> Air",
            "",
            "\tinit(rollDownReturn: @escaping (Window) throws -> Air) {",
            "\t\tself.rollDownReturn = rollDownReturn",
            "\t}",
            "",
            "\tfunc rollDown() -> (Window) throws -> Air {",
            "\t\treturn rollDownReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithClosureAndIntParameterAndOptionalReturnClosure_whenGenerate_thenGenerateStub() {
        let closureArgumentType = Type(name: "(String) -> Int", isOptional: false, isClosure: true, prefix: .escaping)
        let closureArgument = ArgumentType(label: "with", name: "mapping", type: closureArgumentType)
        let intType = Type(name: "Int", isOptional: false, isClosure: false)
        let intArgument = ArgumentType(label: nil, name: "count", type: intType)
        let returnType = Type(name: "((Data) -> Void)", isOptional: true, isClosure: true)
        let function = FunctionDeclarationType(name: "start", arguments: [closureArgument, intArgument], returnType: returnType)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar startReturn: ((Data) -> Void)?",
            "",
            "\tfunc start(with mapping: @escaping (String) -> Int, count: Int) -> ((Data) -> Void)? {",
            "\t\treturn startReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithArgument_whenGenerate_thenGenerateStub() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start(a b: Color) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithNoLabelAndArgument_whenGenerate_thenGenerateStub() {
        let argument = ArgumentType(label: "_", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start(_ b: Color) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithTwoArguments_whenGenerate_thenGenerateStub() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let type2 = Type(name: "Color", isOptional: true)
        let argument2 = ArgumentType(label: nil, name: "d", type: type2)
        let function = FunctionDeclarationType(name: "start", arguments: [argument, argument2])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start(a b: Color, d: Color?) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithTwoFunctionWithArgument_whenGenerate_thenGenerateStub() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let function2 = FunctionDeclarationType(name: "stop", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start(a b: Color) {",
            "\t}",
            "",
            "\tfunc stop(a b: Color) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionAndVarible_whenGenerate_thenGenerateStub() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tvar color: Color",
            "",
            "\tinit(color: Color) {",
            "\t\tself.color = color",
            "\t}",
            "",
            "\tfunc start(a b: Color) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithLongNames_whenGenerate_thenStubIsGenerated() {
        let argument = ArgumentType(label: nil, name: "productId", type: type)
        let function = FunctionDeclarationType(name: "startGenerating", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc startGenerating(productId: Color) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithSameFunctionNames_whenGenerate_thenGenerateStub() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let argument2 = ArgumentType(label: "c", name: "d", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let function2 = FunctionDeclarationType(name: "start", arguments: [argument2])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarStub: Car {",
            "",
            "\tfunc start(a b: Color) {",
            "\t}",
            "",
            "\tfunc start(c d: Color) {",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithNoArgumentLabelAndReturnValue_whenGenerate_thenGenerateStub() {
        let argumentType = Type(name: "Int", isOptional: true)
        let argument = ArgumentType(label: "_", name: "value", type: argumentType)
        let returnType = Type(name: "String", isOptional: true)
        let function = FunctionDeclarationType(name: "formattedString", arguments: [argument], returnType: returnType)
        let protocolType = ProtocolType(name: "Formatter", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class FormatterStub: Formatter {",
            "",
            "\tvar formattedStringReturn: String?",
            "",
            "\tfunc formattedString(_ value: Int?) -> String? {",
            "\t\treturn formattedStringReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenEmptyProtocolAndPrivate_whenGenerate_thenGenerateStub() {
        let protocolType = ProtocolType(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, accessLevel: .private, rows: [
            "private class TestTestTestTestTestStub: TestTestTestTestTest {",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithArgumentAndThrowingFunctionWithReturnValue_whenGeneratePublic_thenGenerateStub() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let argumentType = Type(name: "Int", isOptional: true)
        let argument = ArgumentType(label: "_", name: "value", type: argumentType)
        let returnType = Type(name: "String", isOptional: true)
        let function = FunctionDeclarationType(name: "formattedString", arguments: [argument], isThrowing: true, returnType: returnType)
        let protocolType = ProtocolType(name: "Formatter", parents: [], variables: [variable], functions: [function])

        equal(protocolType: protocolType, accessLevel: .public, rows: [
            "public class FormatterStub: Formatter {",
            "",
            "\tpublic enum StubError: Error {",
            "\t\tcase stubError",
            "\t}",
            "\tpublic typealias ThrowBlock = () throws -> Void",
            "",
            "\tpublic var color: Color",
            "",
            "\tpublic var formattedStringThrowBlock: ThrowBlock?",
            "\tpublic var formattedStringReturn: String?",
            "",
            "\tpublic init(color: Color) {",
            "\t\tself.color = color",
            "\t}",
            "",
            "\tpublic func formattedString(_ value: Int?) throws -> String? {",
            "\t\ttry formattedStringThrowBlock?()",
            "\t\treturn formattedStringReturn",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolSimpleFunction_whenGeneratePublic_thenGenerateStubWithEmptyInit() {
        let function = FunctionDeclarationType(name: "go", arguments: [], isThrowing: false, returnType: nil)
        let protocolType = ProtocolType(name: "Formatter", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, accessLevel: .public, rows: [
            "public class FormatterStub: Formatter {",
            "",
            "\tpublic init() {",
            "\t}",
            "",
            "\tpublic func go() {",
            "\t}",
            "}",
            "",
        ])
    }

    private func equal(protocolType: ProtocolType, accessLevel: AccessLevel = .internal, rows: [String], line: UInt = #line) {
        generator = CreateStubInteractor(accessLevel: accessLevel)
        let generatedRows = generator.generate(from: protocolType).components(separatedBy: "\n")

        XCTAssertEqual(generatedRows.count, rows.count, line: line)
        var index: UInt = 1

        for (line1, line2) in zip(generatedRows, rows) {
            XCTAssertEqual(line1, line2, line: line + index)
            index += 1
        }
    }
}
