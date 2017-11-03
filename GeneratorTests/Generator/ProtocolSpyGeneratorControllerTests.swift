//
//  ProtocolSpyGeneratorControllerTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest
import Generator

class ProtocolSpyGeneratorControllerTests: XCTestCase {

    private let generator = ProtocolSpyGeneratorController()
    private let type = Type(name: "Color", isOptional: false)

    func test_givenprotocolType_whenGenerate_thenGenerateEmptySpy() {
        let protocolType = ProtocolType(name: "Test", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "class TestSpy: Test {",
            "}",
            "",
        ]
        )
    }

    func test_givenprotocolTypeWithLongName_whenGenerate_thenGenerateEmptySpy() {
        let protocolType = ProtocolType(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "class TestTestTestTestTestSpy: TestTestTestTestTest {",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateSpy() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar _color: Color!",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\treturn _color",
            "\t\t}",
            "\t\tset {",
            "\t\t\t_color = newValue",
            "\t\t}",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithConstant_whenGenerate_thenGenerateSpy() {
        let type = Type(name: "Color", isOptional: false)
        let variable = VarDeclarationType(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar _color: Color!",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\treturn _color",
            "\t\t}",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithOptional_whenGenerate_thenGenerateSpy() {
        let type = Type(name: "Color", isOptional: true)
        let variable = VarDeclarationType(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar _color: Color?",
            "\tvar color: Color? {",
            "\t\tget {",
            "\t\t\treturn _color",
            "\t\t}",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithTwoVariables_whenGenerate_thenGenerateSpy() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable, variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar _color: Color!",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\treturn _color",
            "\t\t}",
            "\t\tset {",
            "\t\t\t_color = newValue",
            "\t\t}",
            "\t}",
            "\tvar _color: Color!",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\treturn _color",
            "\t\t}",
            "\t\tset {",
            "\t\t\t_color = newValue",
            "\t\t}",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithSimpleFunction_whenGenerate_thenGenerateSpy() {
        let function = FunctionDeclarationType(name: "start")
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar startCount = 0",
            "",
            "\tfunc start() {",
            "\t\tstartCount += 1",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithFunctionWithReturn_whenGenerate_thenGenerateSpy() {
        let function = FunctionDeclarationType(name: "start", returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar startCount = 0",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start() -> Int {",
            "\t\tstartCount += 1",
            "\t\treturn startReturn",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithThrowingFunction_whenGenerate_thenGenerateSpy() {
        let function = FunctionDeclarationType(name: "start", isThrowing: true, returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tenum CarSpyError: Error {",
            "\t\tcase spyError",
            "\t}",
            "\ttypealias ThrowBlock = () throws -> Void",
            "",
            "\tvar startCount = 0",
            "\tvar startThrowBlock: ThrowBlock?",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start() throws -> Int {",
            "\t\tstartCount += 1",
            "\t\ttry startThrowBlock?()",
            "\t\treturn startReturn",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }
    
    func test_givenProtocolWithThrowingFunctionWithArguments_whenGenerate_thenGenerateSpy() {
        let argument = ArgumentType(label: "with", name: "label", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument], isThrowing: true, returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])
        
        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tenum CarSpyError: Error {",
            "\t\tcase spyError",
            "\t}",
            "\ttypealias ThrowBlock = () throws -> Void",
            "",
            "\tstruct Start {",
            "\t\tlet label: Color",
            "\t}",
            "",
            "\tvar start = [Start]()",
            "\tvar startThrowBlock: ThrowBlock?",
            "\tvar startReturn: Int",
            "",
            "\tinit(startReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t}",
            "",
            "\tfunc start(with label: Color) throws -> Int {",
            "\t\tlet item = Start(label: label)",
            "\t\tstart.append(item)",
            "\t\ttry startThrowBlock?()",
            "\t\treturn startReturn",
            "\t}",
            "",
            "}",
            "",
            ]
        )
    }

    func test_givenProtocolWithMultipleReturnFunctions_whenGenerate_thenGenerateSpy() {
        let function = FunctionDeclarationType(name: "start", returnType: Type(name: "Int", isOptional: false))
        let function2 = FunctionDeclarationType(name: "stop", returnType: Type(name: "Int", isOptional: false))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar startCount = 0",
            "\tvar startReturn: Int",
            "\tvar stopCount = 0",
            "\tvar stopReturn: Int",
            "",
            "\tinit(startReturn: Int, stopReturn: Int) {",
            "\t\tself.startReturn = startReturn",
            "\t\tself.stopReturn = stopReturn",
            "\t}",
            "",
            "\tfunc start() -> Int {",
            "\t\tstartCount += 1",
            "\t\treturn startReturn",
            "\t}",
            "",
            "\tfunc stop() -> Int {",
            "\t\tstopCount += 1",
            "\t\treturn stopReturn",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithFunctionWithArgument_whenGenerate_thenGenerateSpy() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tstruct Start {",
            "\t\tlet b: Color",
            "\t}",
            "",
            "\tvar start = [Start]()",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tlet item = Start(b: b)",
            "\t\tstart.append(item)",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithFunctionWithNoLabelAndArgument_whenGenerate_thenGenerateSpy() {
        let argument = ArgumentType(label: "_", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tstruct Start {",
            "\t\tlet b: Color",
            "\t}",
            "",
            "\tvar start = [Start]()",
            "",
            "\tfunc start(_ b: Color) {",
            "\t\tlet item = Start(b: b)",
            "\t\tstart.append(item)",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithFunctionWithTwoArguments_whenGenerate_thenGenerateSpy() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let type2 = Type(name: "Color", isOptional: true)
        let argument2 = ArgumentType(label: nil, name: "d", type: type2)
        let function = FunctionDeclarationType(name: "start", arguments: [argument, argument2])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tstruct Start {",
            "\t\tlet b: Color",
            "\t\tlet d: Color?",
            "\t}",
            "",
            "\tvar start = [Start]()",
            "",
            "\tfunc start(a b: Color, d: Color?) {",
            "\t\tlet item = Start(b: b, d: d)",
            "\t\tstart.append(item)",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithTwoFunctionWithArgument_whenGenerate_thenGenerateSpy() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let function2 = FunctionDeclarationType(name: "stop", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tstruct Start {",
            "\t\tlet b: Color",
            "\t}",
            "",
            "\tstruct Stop {",
            "\t\tlet b: Color",
            "\t}",
            "",
            "\tvar start = [Start]()",
            "\tvar stop = [Stop]()",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tlet item = Start(b: b)",
            "\t\tstart.append(item)",
            "\t}",
            "",
            "\tfunc stop(a b: Color) {",
            "\t\tlet item = Stop(b: b)",
            "\t\tstop.append(item)",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithFunctionAndVarible_whenGenerate_thenGenerateSpy() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar _color: Color!",
            "\tvar color: Color {",
            "\t\tget {",
            "\t\t\treturn _color",
            "\t\t}",
            "\t\tset {",
            "\t\t\t_color = newValue",
            "\t\t}",
            "\t}",
            "",
            "\tstruct Start {",
            "\t\tlet b: Color",
            "\t}",
            "",
            "\tvar start = [Start]()",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tlet item = Start(b: b)",
            "\t\tstart.append(item)",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithLongNames_whenGenerate_thenSpyIsGenerated() {
        let argument = ArgumentType(label: nil, name: "productId", type: type)
        let function = FunctionDeclarationType(name: "startGenerating", arguments: [argument])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tstruct StartGenerating {",
            "\t\tlet productId: Color",
            "\t}",
            "",
            "\tvar startGenerating = [StartGenerating]()",
            "",
            "\tfunc startGenerating(productId: Color) {",
            "\t\tlet item = StartGenerating(productId: productId)",
            "\t\tstartGenerating.append(item)",
            "\t}",
            "",
            "}",
            "",
        ]
        )
    }

    func test_givenProtocolWithSameFunctionNames_whenGenerate_thenGenerateSpy() {
        let argument = ArgumentType(label: "a", name: "b", type: type)
        let argument2 = ArgumentType(label: "c", name: "d", type: type)
        let function = FunctionDeclarationType(name: "start", arguments: [argument])
        let function2 = FunctionDeclarationType(name: "start", arguments: [argument2])
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tstruct StartA {",
            "\t\tlet b: Color",
            "\t}",
            "",
            "\tstruct StartC {",
            "\t\tlet d: Color",
            "\t}",
            "",
            "\tvar startA = [StartA]()",
            "\tvar startC = [StartC]()",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tlet item = StartA(b: b)",
            "\t\tstartA.append(item)",
            "\t}",
            "",
            "\tfunc start(c d: Color) {",
            "\t\tlet item = StartC(d: d)",
            "\t\tstartC.append(item)",
            "\t}",
            "",
            "}",
            "",
        ])
    }

    func test_givenProtocolWithNoArgumentLabelAndReturnValue_whenGenerate_thenGenerateSpy() {
        let argumentType = Type(name: "Int", isOptional: true)
        let argument = ArgumentType(label: "_", name: "value", type: argumentType)
        let returnType = Type(name: "String", isOptional: true)
        let function = FunctionDeclarationType(name: "formattedString", arguments: [argument], returnType: returnType)
        let protocolType = ProtocolType(name: "Formatter", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class FormatterSpy: Formatter {",
            "",
            "\tstruct FormattedString {",
            "\t\tlet value: Int?",
            "\t}",
            "",
            "\tvar formattedString = [FormattedString]()",
            "\tvar formattedStringReturn: String?",
            "",
            "\tfunc formattedString(_ value: Int?) -> String? {",
            "\t\tlet item = FormattedString(value: value)",
            "\t\tformattedString.append(item)",
            "\t\treturn formattedStringReturn",
            "\t}",
            "",
            "}",
            "",
        ])
    }

    func test_givenEmptyProtocolAndPrivate_whenGenerate_thenGenerateSpy() {
        let protocolType = ProtocolType(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, visibility: "private", rows: [
            "private class TestTestTestTestTestSpy: TestTestTestTestTest {",
            "}",
            "",
        ]
        )
    }

    private func equal(protocolType: ProtocolType, visibility: String? = nil, rows: [String]) {
        let generatedRows = generator.generate(from: protocolType, visibility: visibility).components(separatedBy: "\n")

        XCTAssertEqual(generatedRows.count, rows.count)

        _ = zip(generatedRows, rows).forEach({
            XCTAssertEqual($0, $1)
        })
    }
}
