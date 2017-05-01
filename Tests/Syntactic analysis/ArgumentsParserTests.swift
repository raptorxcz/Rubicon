//
//  ArgumentsParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class ArgumentsParserTests: XCTestCase {

    func test_init() {
        _ = ArgumentsParser()
    }

    func test_givenEmptyParameters_whenParse_thenParseHelp() {
        let argumentsParser = ArgumentsParser()
        let arguments = argumentsParser.parse(arguments: [])

        guard case .help = arguments else {
            XCTFail()
            return
        }
    }

    func test_givenMocksWithoutPath_whenParse_thenParseHelp() {
        let argumentsParser = ArgumentsParser()
        let arguments = argumentsParser.parse(arguments: ["--mocks"])

        guard case .help = arguments else {
            XCTFail()
            return
        }
    }

    func test_givenMocksWithPath_whenParse_thenParseMocks() {
        let argumentsParser = ArgumentsParser()
        let arguments = argumentsParser.parse(arguments: ["--mocks", "."])

        guard case .mocks(let path) = arguments else {
            XCTFail()
            return
        }

        XCTAssertEqual(path, ".")
    }

}
