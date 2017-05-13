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
        let protocolType = ProtocolType(name: "Test", variables: [], functions: [])

        equal(protocolType: protocolType, rows: [
            "class TestSpy: Test {",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenprotocolTypeWithLongName_whenGenerate_thenGenerateEmptySpy() {
        let protocolType = ProtocolType(name: "TestTestTestTestTest", variables: [], functions: [])

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
        let protocolType = ProtocolType(name: "Car", variables: [variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var color: Color!",
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
        let protocolType = ProtocolType(name: "Car", variables: [variable], functions: [])
        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var color: Color!",
            "",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenProtocolWithTwoVariables_whenGenerate_thenGenerateSpy() {
        let variable = VarDeclarationType(isConstant: false, identifier: "color", type: type)
        let protocolType = ProtocolType(name: "Car", variables: [variable, variable], functions: [])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var color: Color!",
            "var color: Color!",
            "",
            "}",
            "",
            ""
            ]
        )
    }

    func test_givenProtocolWithSimpleFunction_whenGenerate_thenGenerateSpy() {
        let function = FunctionDeclarationType(name: "start", arguments: [])
        let protocolType = ProtocolType(name: "Car", variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var startCount = 0",
            "",
            "func start() {",
            "startCount += 1",
            "}",
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
        let protocolType = ProtocolType(name: "Car", variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var startACount = 0",
            "var startAB: Color?",
            "",
            "func start(a b: Color) {",
            "startACount += 1",
            "startAB = b",
            "}",
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
        let protocolType = ProtocolType(name: "Car", variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var start_Count = 0",
            "var start_B: Color?",
            "",
            "func start(_ b: Color) {",
            "start_Count += 1",
            "start_B = b",
            "}",
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
        let protocolType = ProtocolType(name: "Car", variables: [], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var startACount = 0",
            "var startAB: Color?",
            "var startAD: Color?",
            "",
            "func start(a b: Color, d: Color?) {",
            "startACount += 1",
            "startAB = b",
            "startAD = d",
            "}",
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
        let protocolType = ProtocolType(name: "Car", variables: [], functions: [function, function2])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var startACount = 0",
            "var startAB: Color?",
            "",
            "var stopACount = 0",
            "var stopAB: Color?",
            "",
            "func start(a b: Color) {",
            "startACount += 1",
            "startAB = b",
            "}",
            "",
            "func stop(a b: Color) {",
            "stopACount += 1",
            "stopAB = b",
            "}",
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
        let protocolType = ProtocolType(name: "Car", variables: [variable], functions: [function])

        equal(protocolType: protocolType, rows: [
            "class CarSpy: Car {",
            "",
            "var color: Color!",
            "",
            "var startACount = 0",
            "var startAB: Color?",
            "",
            "func start(a b: Color) {",
            "startACount += 1",
            "startAB = b",
            "}",
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
