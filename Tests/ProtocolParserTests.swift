//
//  ProtocolParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class ProtocolParserTests: XCTestCase {

    let parser = ProtocolParser()

    func test_givenInvalidToken_whenParse_thenThrowException() {
        let storage = try! Storage(tokens: [.colon])
        testParserException(with: storage, .invalidProtocolToken)
    }

    func test_givenInvalidNameToken_whenParse_thenThrowException() {
        let storage = try! Storage(tokens: [.protocol, .colon])
        testParserException(with: storage, .invalidNameToken)
    }

    func test_givenInvalidLeftBracketToken_whenParse_thenThrowException() {
        let storage = try! Storage(tokens: [.protocol, .identifier(name: "p"), .colon])
        testParserException(with: storage, .expectedLeftBracket)
    }

    func test_givenInvalidRightBracketToken_whenParse_thenThrowException() {
        let storage = try! Storage(tokens: [.protocol, .identifier(name: "p"), .leftCurlyBracket, .colon])
        testParserException(with: storage, .expectedRightBracket)
    }

    func test_givenEmptyProtocol_whenParse_thenParse() {
        let storage = try! Storage(tokens: [.protocol, .identifier(name: "p"), .leftCurlyBracket, .rightCurlyBracket, .colon])
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    private func testParserException(with storage: Storage, _ exception: ProtocolParserError) {
        testException(with: exception, parse: {
            _ = try parser.parse(storage: storage)
        })
    }
}
