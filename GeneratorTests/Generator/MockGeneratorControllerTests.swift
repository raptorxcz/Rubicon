//
//  MockGeneratorControllerTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest
import Generator

class MockGeneratorControllerTests: XCTestCase {

    func test_givenEmptyString_whenRun_thenGenerateEmptyString() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "")
        XCTAssertEqual(generatorOutput.text, "")
        XCTAssertEqual(generatorOutput.saveCount, 1)
    }

    func test_givenNoProtocol_whenRun_thenGenerateEmptyString() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "class X {")
        XCTAssertEqual(generatorOutput.text, "")
        XCTAssertEqual(generatorOutput.saveCount, 0)
    }

    func test_givenIncompleteProtocol_whenRun_thenGenerateEmptyString() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "protocol X {")
        XCTAssertEqual(generatorOutput.text, "")
        XCTAssertEqual(generatorOutput.saveCount, 1)
    }

    func test_givenEmptyProtocol_whenRun_thenGenerateEmptySpy() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "protocol X {}")
        XCTAssertEqual(generatorOutput.text, "class XSpy: X {\n}\n\n")
        XCTAssertEqual(generatorOutput.saveCount, 1)
    }

    func test_givenEmptyProtocolInContext_whenRun_thenGenerateEmptySpy() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "class {} protocol X {}")
        XCTAssertEqual(generatorOutput.text, "class XSpy: X {\n}\n\n")
        XCTAssertEqual(generatorOutput.saveCount, 1)
    }

    func test_givenTwoEmptyProtocolsInContext_whenRun_thenGenerateEmptySpy() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "class {} protocol X {} var X protocol Y {}")
        XCTAssertEqual(generatorOutput.text, "class XSpy: X {\n}\n\nclass YSpy: Y {\n}\n\n")
        XCTAssertEqual(generatorOutput.saveCount, 2)
    }

}

private class GeneratorOutputSpy: GeneratorOutput {

    var text = ""
    var saveCount = 0

    func save(text: String) {
        self.text += text
        saveCount += 1
    }

}
