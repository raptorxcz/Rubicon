//
//  MockGeneratorControllerTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class MockGeneratorControllerTests: XCTestCase {

    func test_givenEmptyString_whenRun_thenGenerateEmptyString() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "")
        XCTAssertEqual(generatorOutput.text, "")
        XCTAssertEqual(generatorOutput.saveCount, 1)
    }

    func test_givenIncompleteProtocol_whenRun_thenGenerateEmptyString() {
        let generatorOutput = GeneratorOutputSpy()
        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
        generator.run(text: "protocol X {")
        XCTAssertEqual(generatorOutput.text, "")
        XCTAssertEqual(generatorOutput.saveCount, 1)
    }

    //    func test_givenEmptyProtocol_whenRun_thenGenerateEmptySpy() {
    //        let generatorOutput = GeneratorOutputSpy()
    //        let generator = MocksGeneratorControllerImpl(output: generatorOutput)
    //        generator.run(text: "protocol X {}")
    //        XCTAssertEqual(generatorOutput.text, "")
    //        XCTAssertEqual(generatorOutput.saveCount, 1)
    //    }

}

private class GeneratorOutputSpy: GeneratorOutput {

    var text = ""
    var saveCount = 0

    func save(text: String) {
        self.text = text
        saveCount += 1
    }

}
