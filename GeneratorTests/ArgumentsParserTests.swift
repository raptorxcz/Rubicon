//
//  ArgumentsParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Generator
import XCTest

class ArgumentsParserTests: XCTestCase {

    private let argumentsParser = ArgumentsParser()

    func test_givenEmptyParameters_whenParse_thenParseHelp() {
        let arguments = argumentsParser.parse(arguments: [])

        guard case .help = arguments else {
            XCTFail()
            return
        }
    }

    func test_givenMocksWithoutPath_whenParse_thenParseHelp() {
        let arguments = argumentsParser.parse(arguments: ["--mocks"])

        guard case .help = arguments else {
            XCTFail()
            return
        }
    }

    func test_givenMocksWithPath_whenParse_thenParseMocks() {
        let arguments = argumentsParser.parse(arguments: ["--mocks", "."])

        guard case let .mocks(path) = arguments else {
            XCTFail()
            return
        }

        XCTAssertEqual(path, ".")
    }
}
