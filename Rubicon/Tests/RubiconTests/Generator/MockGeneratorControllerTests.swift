//
//  MockGeneratorControllerTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

//class MockGeneratorControllerTests: XCTestCase {
//    private var sut: MocksGeneratorControllerImpl!
//    private var generatorOutput: GeneratorOutputSpy!
//
//    override func setUp() {
//        generatorOutput = GeneratorOutputSpy()
//        sut = MocksGeneratorControllerImpl(output: generatorOutput, interactor: CreateSpyInteractor(accessLevel: .internal))
//    }
//
//    func test_givenNoStrings_whenRun_thenGenerateEmptyString() {
//        sut.run(texts: [])
//
//        XCTAssertEqual(generatorOutput.text, "")
//        XCTAssertEqual(generatorOutput.saveCount, 0)
//    }
//
//    func test_givenEmptyString_whenRun_thenGenerateEmptyString() {
//        sut.run(texts: [""])
//
//        XCTAssertEqual(generatorOutput.text, "")
//        XCTAssertEqual(generatorOutput.saveCount, 0)
//    }
//
//    func test_givenStringsWithNoProtocolKeyword_whenRun_thenGenerateEmptyString() {
//        sut.run(texts: ["a", "Ad", "vc"])
//
//        XCTAssertEqual(generatorOutput.text, "")
//        XCTAssertEqual(generatorOutput.saveCount, 0)
//    }
//
//    func test_givenStringsWithNoToken_whenRun_thenGenerateEmptyString() {
//        sut.run(texts: ["aprotocolxx", "Ad", "vc"])
//
//        XCTAssertEqual(generatorOutput.text, "")
//        XCTAssertEqual(generatorOutput.saveCount, 0)
//    }
//
//    func test_givenNoProtocol_whenRun_thenGenerateEmptyString() {
//        sut.run(texts: ["class X {"])
//
//        XCTAssertEqual(generatorOutput.text, "")
//        XCTAssertEqual(generatorOutput.saveCount, 0)
//    }
//
//    func test_givenIncompleteProtocol_whenRun_thenGenerateEmptyString() {
//        sut.run(texts: ["protocol X {"])
//
//        XCTAssertEqual(generatorOutput.text, "")
//        XCTAssertEqual(generatorOutput.saveCount, 1)
//    }
//
//    func test_givenEmptyProtocol_whenRun_thenGenerateEmptySpy() {
//        sut.run(texts: ["protocol X {}"])
//
//        XCTAssertEqual(generatorOutput.text, "final class XSpy: X {\n}\n")
//        XCTAssertEqual(generatorOutput.saveCount, 1)
//    }
//
//    func test_givenEmptyProtocolInContext_whenRun_thenGenerateEmptySpy() {
//        sut.run(texts: ["class {} protocol X {}"])
//
//        XCTAssertEqual(generatorOutput.text, "final class XSpy: X {\n}\n")
//        XCTAssertEqual(generatorOutput.saveCount, 1)
//    }
//
//    func test_givenTwoEmptyProtocolsInContext_whenRun_thenGenerateEmptySpy() {
//        sut.run(texts: ["", "class {} protocol X {} var X protocol Y {}"])
//
//        XCTAssertEqual(generatorOutput.text, "final class XSpy: X {\n}\nfinal class YSpy: Y {\n}\n")
//        XCTAssertEqual(generatorOutput.saveCount, 2)
//    }
//}
//
//private class GeneratorOutputSpy: GeneratorOutput {
//    var text = ""
//    var saveCount = 0
//
//    func save(text: String) {
//        self.text += text
//        saveCount += 1
//    }
//}
