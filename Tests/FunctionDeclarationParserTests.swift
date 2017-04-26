//
//  FunctionDeclarationParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class FunctionDeclarationParserTests: XCTestCase {

    let parser = FunctionDeclarationParser()

    func test_givenColon_whenParse_thenThrowException() {
        let storage = try! Storage(tokens: [.colon])
        testParserException(with: storage, .invalidFunctionToken)
    }

    func test_givenInvalidNameToken_whenParse_thenThrowInvalidNameException() {
        let storage = try! Storage(tokens: [.function, .colon])
        testParserException(with: storage, .invalidNameToken)
    }

    func test_givenInvalidLeftBracketNameToken_whenParse_thenThrowInvalidNameException() {
        let storage = try! Storage(tokens: [.function, .identifier(name: "f"), .colon])
        testParserException(with: storage, .invalidLeftBracketToken)
    }

    func test_givenInvalidFunctionArgument_whenParse_thenThrowInvalidFunctionArgumentException() {
        let storage = try! Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .colon])
        testParserException(with: storage, .invalidFunctionArgument)
    }

    func test_givenFunction_whenParse_thenParse() {
        let storage = try! Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .colon])
        do {
            let definition = try parser.parse(storage: storage)
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    private func testParserException(with storage: Storage, _ exception: FunctionDeclarationParserError) {
        testException(with: exception, parse: {
            _ = try parser.parse(storage: storage)
        })
    }
}
