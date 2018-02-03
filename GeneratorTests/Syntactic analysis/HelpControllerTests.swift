//
//  HelpControllerTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Generator
import XCTest

class HelpControllerTests: XCTestCase {

    func test_whenRun_thenSendHelpAtOutput() {
        let outputSpy = ErrorGeneratorOutputSpy()
        let helpController = HelpControllerImpl(output: outputSpy)
        helpController.run()
        XCTAssertEqual(outputSpy.showErrorCount, 1)
        XCTAssertEqual(outputSpy.showErrorText, "Required arguments:\n--mocks path\n")
    }
}

private class ErrorGeneratorOutputSpy: ErrorGeneratorOutput {

    var showErrorText: String = ""
    var showErrorCount = 0

    func showError(text: String) {
        showErrorCount += 1
        showErrorText = text
    }
}
