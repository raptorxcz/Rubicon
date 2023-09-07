//
//  ArgumentParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 27/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

class ArgumentParserTests: XCTestCase {

    let parser = ArgumentParser()

    func test_givenInvalidToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.colon])
        testParserException(with: storage, .invalidName)
    }

    func test_givenNoSecondToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.identifier(name: "name")])

        testParserException(with: storage, .invalidColon)
    }

    func test_givenInvalidColonToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.identifier(name: "name"), .leftBracket])
        testParserException(with: storage, .invalidColon)
    }

    func test_givenInvalidTypeToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.identifier(name: "name"), .colon, .leftBracket])
        testParserException(with: storage, .invalidType)
    }

    func test_givenArgument_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "name"), .colon, .identifier(name: "Int"), .colon])
        do {
            let argumenType = try parser.parse(storage: storage)
            XCTAssertEqual(argumenType.label, nil)
            XCTAssertEqual(argumenType.name, "name")
            XCTAssertEqual(argumenType.type.name, "Int")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenArgumentWithLabel_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "label"), .identifier(name: "name"), .colon, .identifier(name: "Int"), .colon])
        do {
            let argumenType = try parser.parse(storage: storage)
            XCTAssertEqual(argumenType.label, "label")
            XCTAssertEqual(argumenType.name, "name")
            XCTAssertEqual(argumenType.type.name, "Int")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenArgumentClosureType_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "name"), .colon, .leftBracket, .rightBracket, .arrow, .identifier(name: "Void")])
        do {
            let argumenType = try parser.parse(storage: storage)
            XCTAssertEqual(argumenType.label, nil)
            XCTAssertEqual(argumenType.name, "name")
            XCTAssertEqual(argumenType.type.name, "() -> Void")
        } catch {
            XCTFail()
        }
    }

    func test_givenArgumentEscapingClosureType_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "name"), .colon, .escaping, .leftBracket, .identifier(name: "Input"), .rightBracket, .arrow, .identifier(name: "Result")])
        do {
            let argumenType = try parser.parse(storage: storage)
            XCTAssertEqual(argumenType.label, nil)
            XCTAssertEqual(argumenType.name, "name")
            XCTAssertEqual(argumenType.type.name, "(Input) -> Result")
            XCTAssertEqual(argumenType.type.isClosure, true)
            XCTAssertEqual(argumenType.type.prefix, .escaping)
        } catch {
            XCTFail()
        }
    }

    private func testParserException(with storage: Storage, _ exception: ArgumentParserError) {
        testException(with: exception, parse: {
            _ = try parser.parse(storage: storage)
        })
    }
}
