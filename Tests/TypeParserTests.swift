//
//  TypeParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class TypeParserTests: XCTestCase {

    let parser = TypeParser()

    func test_givenColonToken_whenParse_thenThrowException() {
        let storage = try! Storage(tokens: [.colon])

        testException(with: TypeParserError.invalidName) { 
            _ = try parser.parse(storage: storage)

        }
    }

    func test_givenNameToken_whenParse_thenParse() {
        let storage = try! Storage(tokens: [.identifier(name: "x")])

        do {
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.name, "x")
            XCTAssertEqual(type.isOptional, false)
        } catch {
            XCTFail()
        }
    }

    func test_givenNameColonTokens_whenParse_thenParse() {
        let storage = try! Storage(tokens: [.identifier(name: "x"), .colon])

        do {
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.name, "x")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenNameQuestionMarkTokens_whenParse_thenParse() {
        let storage = try! Storage(tokens: [.identifier(name: "x"), .questionMark, .colon])

        do {
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.name, "x")
            XCTAssertEqual(type.isOptional, true)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

}
