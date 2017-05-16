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
            ""
            ]
        )
    }

    func test_givenprotocolTypeWithLongName_whenGenerate_thenGenerateEmptySpy() {
        let protocolType = ProtocolType(name: "TestTestTestTestTest", parents: [], variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "class TestTestTestTestTestSpy: TestTestTestTestTest {",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenProtocolWithVariable_whenGenerate_thenGenerateSpy() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar color: Color!",
            "",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenProtocolWithConstant_whenGenerate_thenGenerateSpy() {
        let type = Type(name: "Color", isOptional: true)
        let variable = VarDeclarationType(isConstant: true, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar color: Color!",
            "",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenProtocolWithTwoVariables_whenGenerate_thenGenerateSpy() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [variable, variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar color: Color!",
            "\tvar color: Color!",
            "",
            "}",
            "",
            ""
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
            ""
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
            "\tvar startReturn: Int!",
            "",
            "\tfunc start() -> Int {",
            "\t\tstartCount += 1",
            "\t\treturn startReturn",
            "\t}",
            "",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenProtocolWithFunctionWithOptionalReturn_whenGenerate_thenGenerateSpy() {
        let function = FunctionDeclarationType(name: "start", returnType: Type(name: "Int", isOptional: true))
        let protocolType = ProtocolType(name: "Car", parents: [], variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "\tvar startCount = 0",
            "\tvar startReturn: Int?",
            "",
            "\tfunc start() -> Int? {",
            "\t\tstartCount += 1",
            "\t\treturn startReturn",
            "\t}",
            "",
            "}",
            "",
            ""
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
            "\tvar startACount = 0",
            "\tvar startAB: Color?",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tstartACount += 1",
            "\t\tstartAB = b",
            "\t}",
            "",
            "}",
            "",
            ""
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
            "\tvar start_Count = 0",
            "\tvar start_B: Color?",
            "",
            "\tfunc start(_ b: Color) {",
            "\t\tstart_Count += 1",
            "\t\tstart_B = b",
            "\t}",
            "",
            "}",
            "",
            ""
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
            "\tvar startACount = 0",
            "\tvar startAB: Color?",
            "\tvar startAD: Color?",
            "",
            "\tfunc start(a b: Color, d: Color?) {",
            "\t\tstartACount += 1",
            "\t\tstartAB = b",
            "\t\tstartAD = d",
            "\t}",
            "",
            "}",
            "",
            ""
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
            "\tvar startACount = 0",
            "\tvar startAB: Color?",
            "",
            "\tvar stopACount = 0",
            "\tvar stopAB: Color?",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tstartACount += 1",
            "\t\tstartAB = b",
            "\t}",
            "",
            "\tfunc stop(a b: Color) {",
            "\t\tstopACount += 1",
            "\t\tstopAB = b",
            "\t}",
            "",
            "}",
            "",
            ""
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
            "\tvar color: Color!",
            "",
            "\tvar startACount = 0",
            "\tvar startAB: Color?",
            "",
            "\tfunc start(a b: Color) {",
            "\t\tstartACount += 1",
            "\t\tstartAB = b",
            "\t}",
            "",
            "}",
            "",
            ""
            ]
        )
    }

    private func equal(protocolType: ProtocolType, rows: [String]) {
        let generatedRows = generator.generate(from: protocolType).components(separatedBy: "\n")

        XCTAssertEqual(generatedRows.count, rows.count)

        _ = zip(generatedRows, rows).forEach({
            XCTAssertEqual($0, $1)
        })
    }

}
