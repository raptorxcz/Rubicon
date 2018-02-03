//
//  ArgumentsControllerTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Generator
import XCTest

class ArgumentsControllerTests: XCTestCase {

    func test_givenInvalidArguments_whenRun_thenShowHelp() {
        let fileReaderSpy = FileReaderSpy()
        let helpControllerSpy = HelpControllerSpy()
        let argumentsController = ArgumentsController(fileReader: fileReaderSpy, helpController: helpControllerSpy, mocksController: MocksGeneratorControllerSpy())
        argumentsController.run(arguments: ["sd"])
        XCTAssertEqual(helpControllerSpy.runCount, 1)
    }

    func test_givenMocksArguments_whenRun_thenReadFile() {
        let fileReaderSpy = FileReaderSpy()
        let helpControllerSpy = HelpControllerSpy()
        let mocksControllerSpy = MocksGeneratorControllerSpy()
        let argumentsController = ArgumentsController(fileReader: fileReaderSpy, helpController: helpControllerSpy, mocksController: mocksControllerSpy)
        argumentsController.run(arguments: ["rubicon", "--mocks", "*"])
        XCTAssertEqual(fileReaderSpy.readFilesCount, 1)
        XCTAssertEqual(fileReaderSpy.path, "*")
        XCTAssertEqual(helpControllerSpy.runCount, 0)
    }

    func test_givenMocksArguments_whenRun_thenParseToStorage() {
        let fileReaderSpy = FileReaderSpy()
        fileReaderSpy.result = "protocol string"
        let mocksControllerSpy = MocksGeneratorControllerSpy()
        let argumentsController = ArgumentsController(fileReader: fileReaderSpy, helpController: HelpControllerSpy(), mocksController: mocksControllerSpy)
        argumentsController.run(arguments: ["rubicon", "--mocks", "*"])
        XCTAssertEqual(mocksControllerSpy.runCount, 1)
        XCTAssertEqual(mocksControllerSpy.text, "protocol string")
    }
}

private class FileReaderSpy: FileReader {

    var readFilesCount = 0
    var path = ""
    var result = ""

    func readFiles(at path: String) -> String {
        readFilesCount += 1
        self.path = path
        return result
    }
}

private class HelpControllerSpy: HelpController {

    var runCount = 0

    func run() {
        runCount += 1
    }
}

private class MocksGeneratorControllerSpy: MocksGeneratorController {

    var runCount = 0
    var text = ""

    func run(text: String) {
        runCount += 1
        self.text = text
    }
}
