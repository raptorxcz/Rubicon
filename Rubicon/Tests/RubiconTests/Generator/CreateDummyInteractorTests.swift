//
//  CreateDummyInteractorTests.swift
//  GeneratorTests
//
//  Created by Kryštof Matěj on 15/02/2019.
//  Copyright © 2019 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

class CreateDummyInteractorTests: XCTestCase {
    private var generator: CreateDummyInteractor!
    private let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)

    func test_givenprotocolType_whenGenerate_thenGenerateEmptyDummy() {
        let protocolType = ProtocolDeclaration(name: "Test", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "final class TestDummy: Test {",
            "}",
            "",
        ])
    }

    func test_givenprotocolTypeWithLongName_whenGenerate_thenGenerateEmptyDummy() {
        let protocolType = ProtocolDeclaration(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "final class TestTestTestTestTestDummy: TestTestTestTestTest {",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateDummy() {
        let variable = VarDeclaration(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithEscapingClosureVariable_whenGenerate_thenGenerateDummy() {
        let type = TypeDeclaration.makeStub(name: "(() -> Void)", isOptional: false, isClosure: true)
        let variable = VarDeclaration(isConstant: false, identifier: "closeBlock", type: type)
        let protocolType = ProtocolDeclaration(name: "Door", parents: [], variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "final class DoorDummy: Door {",
            "",
            "\tvar closeBlock: (() -> Void) {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithConstant_whenGenerate_thenGenerateDummy() {
        let type = TypeDeclaration.makeStub(name: "Color", isOptional: false)
        let variable = VarDeclaration(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tvar color: Color {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithOptional_whenGenerate_thenGenerateDummy() {
        let type = TypeDeclaration.makeStub(name: "Color", isOptional: true)
        let variable = VarDeclaration(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tvar color: Color? {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithTwoVariables_whenGenerate_thenGenerateDummy() {
        let variable1 = VarDeclaration(isConstant: false, identifier: "color1", type: type)
        let variable2 = VarDeclaration(isConstant: false, identifier: "color2", type: type)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [variable1, variable2], functions: [])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tvar color1: Color {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "\tvar color2: Color {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithSimpleFunction_whenGenerate_thenGenerateDummy() {
        let function = FunctionDeclaration(name: "start")
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start() {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithReturn_whenGenerate_thenGenerateDummy() {
        let function = FunctionDeclaration(name: "start", returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start() -> Int {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithAsyncFunction_whenGenerate_thenGenerateDummy() {
        let function = FunctionDeclaration(name: "start", isAsync: true, returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start() async -> Int {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithThrowingFunction_whenGenerate_thenGenerateDummy() {
        let function = FunctionDeclaration(name: "start", isThrowing: true, returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start() throws -> Int {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithThrowingAndAsyncFunction_whenGenerate_thenGenerateDummy() {
        let function = FunctionDeclaration(name: "start", isThrowing: true, isAsync: true, returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start() async throws -> Int {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithThrowingFunctionWithArguments_whenGenerate_thenGenerateDummy() {
        let argument = ArgumentDeclaration(label: "with", name: "label", type: type)
        let function = FunctionDeclaration(name: "start", arguments: [argument], isThrowing: true, returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(with label: Color) throws -> Int {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithMultipleReturnFunctions_whenGenerate_thenGenerateDummy() {
        let function = FunctionDeclaration(name: "start", returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let function2 = FunctionDeclaration(name: "stop", returnType: TypeDeclaration.makeStub(name: "Int", isOptional: false))
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start() -> Int {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tfunc stop() -> Int {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithEscapingType_whenGenerate_thenGenerateDummy() {
        let argumentType = TypeDeclaration.makeStub(name: "ActionBlock", isOptional: false, isClosure: true, prefix: .escaping)
        let argument = ArgumentDeclaration(label: "with", name: "action", type: argumentType)
        let function = FunctionDeclaration(name: "start", arguments: [argument], returnType: nil)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(with action: @escaping ActionBlock) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithClosureParameterAndReturnClosure_whenGenerate_thenGenerateDummy() {
        let argumentType = TypeDeclaration.makeStub(name: "(String) -> Int", isOptional: false, isClosure: true, prefix: .escaping)
        let argument = ArgumentDeclaration(label: "with", name: "mapping", type: argumentType)
        let returnType = TypeDeclaration.makeStub(name: "(Data) -> Void", isOptional: false, isClosure: true)
        let function = FunctionDeclaration(name: "start", arguments: [argument], returnType: returnType)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(with mapping: @escaping (String) -> Int) -> (Data) -> Void {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithThrowingAutoclosureArgument_whenGenerate_thenGenerateDummy() {
        let type = TypeDeclaration.makeStub(name: "(Window) throws -> Air", isOptional: false, isClosure: true)
        let function = FunctionDeclaration(name: "rollDown", arguments: [], returnType: type)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc rollDown() -> (Window) throws -> Air {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithClosureAndIntParameterAndOptionalReturnClosure_whenGenerate_thenGenerateDummy() {
        let closureArgumentType = TypeDeclaration.makeStub(name: "(String) -> Int", isOptional: false, isClosure: true, prefix: .escaping)
        let closureArgument = ArgumentDeclaration(label: "with", name: "mapping", type: closureArgumentType)
        let intType = TypeDeclaration.makeStub(name: "Int", isOptional: false, isClosure: false)
        let intArgument = ArgumentDeclaration(label: nil, name: "count", type: intType)
        let returnType = TypeDeclaration.makeStub(name: "((Data) -> Void)", isOptional: true, isClosure: true)
        let function = FunctionDeclaration(name: "start", arguments: [closureArgument, intArgument], returnType: returnType)
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(with mapping: @escaping (String) -> Int, count: Int) -> ((Data) -> Void)? {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithArgument_whenGenerate_thenGenerateDummy() {
        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
        let function = FunctionDeclaration(name: "start", arguments: [argument])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithNoLabelAndArgument_whenGenerate_thenGenerateDummy() {
        let argument = ArgumentDeclaration(label: "_", name: "b", type: type)
        let function = FunctionDeclaration(name: "start", arguments: [argument])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(_ b: Color) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionWithTwoArguments_whenGenerate_thenGenerateDummy() {
        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
        let type2 = TypeDeclaration.makeStub(name: "Color", isOptional: true)
        let argument2 = ArgumentDeclaration(label: nil, name: "d", type: type2)
        let function = FunctionDeclaration(name: "start", arguments: [argument, argument2])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(a b: Color, d: Color?) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithTwoFunctionWithArgument_whenGenerate_thenGenerateDummy() {
        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
        let function = FunctionDeclaration(name: "start", arguments: [argument])
        let function2 = FunctionDeclaration(name: "stop", arguments: [argument])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tfunc stop(a b: Color) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithFunctionAndVarible_whenGenerate_thenGenerateDummy() {
        let variable = VarDeclaration(isConstant: false, identifier: "color", type: type)
        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
        let function = FunctionDeclaration(name: "start", arguments: [argument])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [variable], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithLongNames_whenGenerate_thenDummyIsGenerated() {
        let argument = ArgumentDeclaration(label: nil, name: "productId", type: type)
        let function = FunctionDeclaration(name: "startGenerating", arguments: [argument])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc startGenerating(productId: Color) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithSameFunctionNames_whenGenerate_thenGenerateDummy() {
        let argument = ArgumentDeclaration(label: "a", name: "b", type: type)
        let argument2 = ArgumentDeclaration(label: "c", name: "d", type: type)
        let function = FunctionDeclaration(name: "start", arguments: [argument])
        let function2 = FunctionDeclaration(name: "start", arguments: [argument2])
        let protocolType = ProtocolDeclaration(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "final class CarDummy: Car {",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tfunc start(c d: Color) {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithNoArgumentLabelAndReturnValue_whenGenerate_thenGenerateDummy() {
        let argumentType = TypeDeclaration.makeStub(name: "Int", isOptional: true)
        let argument = ArgumentDeclaration(label: "_", name: "value", type: argumentType)
        let returnType = TypeDeclaration.makeStub(name: "String", isOptional: true)
        let function = FunctionDeclaration(name: "formattedString", arguments: [argument], returnType: returnType)
        let protocolType = ProtocolDeclaration(name: "Formatter", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "final class FormatterDummy: Formatter {",
            "",
            "\tfunc formattedString(_ value: Int?) -> String? {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    func test_givenEmptyProtocolAndPrivate_whenGenerate_thenGenerateDummy() {
        let protocolType = ProtocolDeclaration(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, accessLevel: .private, rows: [
            "private final class TestTestTestTestTestDummy: TestTestTestTestTest {",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithArgumentAndThrowingFunctionWithReturnValue_whenGeneratePublic_thenGenerateDummy() {
        let variable = VarDeclaration(isConstant: false, identifier: "color", type: type)
        let variable2 = VarDeclaration(isConstant: true, identifier: "color", type: type)
        let argumentType = TypeDeclaration.makeStub(name: "Int", isOptional: true)
        let argument = ArgumentDeclaration(label: "_", name: "value", type: argumentType)
        let returnType = TypeDeclaration.makeStub(name: "String", isOptional: true)
        let function = FunctionDeclaration(name: "formattedString", arguments: [argument], isThrowing: true, returnType: returnType)
        let protocolType = ProtocolDeclaration(name: "Formatter", parents: [], variables: [variable, variable2], functions: [function])

        equal(protocolType: protocolType, accessLevel: .public, rows: [
            "public final class FormatterDummy: Formatter {",
            "",
            "\tpublic var color: Color {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "\tpublic var color: Color {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tpublic init() {",
            "\t}",
            "",
            "\tpublic func formattedString(_ value: Int?) throws -> String? {",
            "\t\tfatalError()",
            "\t}",
            "}",
            "",
        ])
    }

    private func equal(protocolType: ProtocolDeclaration, accessLevel: AccessLevel = .internal, rows: [String], line: UInt = #line) {
        generator = CreateDummyInteractor(accessLevel: accessLevel)

        let generatedRows = generator.generate(from: protocolType).components(separatedBy: "\n")

        XCTAssertEqual(generatedRows.count, rows.count, line: line)
        var index: UInt = 1

        for (line1, line2) in zip(generatedRows, rows) {
            XCTAssertEqual(line1, line2, line: line + index)
            index += 1
        }
    }
}

extension TypeDeclaration {
    static func makeStub(
        name: String = "Int",
        isOptional: Bool = false,
        isClosure: Bool = false,
        prefix: TypePrefix? = nil,
        existencial: String? = nil
    ) -> TypeDeclaration {
        return TypeDeclaration(
            name: name,
            isOptional: isOptional,
            isClosure: isClosure,
            prefix: prefix,
            existencial: existencial
        )
    }
}
