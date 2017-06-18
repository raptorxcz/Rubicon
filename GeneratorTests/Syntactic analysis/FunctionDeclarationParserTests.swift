//
//  FunctionDeclarationParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest
import Generator

class FunctionDeclarationParserTests: XCTestCase {

    private let argumentTokens: [Token] = [.identifier(name: "a"), .colon, .identifier(name: "Int")]

    func test_givenColon_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.colon])
        testParserException(with: storage, .invalidFunctionToken)
    }

    func test_givenInvalidNameToken_whenParse_thenThrowInvalidNameException() throws {
        let storage = try Storage(tokens: [.function, .colon])
        testParserException(with: storage, .invalidNameToken)
    }

    func test_givenInvalidLeftBracketNameToken_whenParse_thenThrowInvalidNameException() throws {
        let storage = try Storage(tokens: [.function, .identifier(name: "f"), .colon])
        testParserException(with: storage, .invalidLeftBracketToken)
    }

    func test_givenInvalidFunctionArgument_whenParse_thenThrowInvalidFunctionArgumentException() throws {
        let storage = try Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .colon])
        testParserException(with: storage, .invalidFunctionArgument)
        XCTAssertEqual(storage.current, .function)
    }

    func test_givenFunction_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .colon])
        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.isThrowing, false)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenFunctionWithArgument_whenParse_thenParse() throws {
        var tokens: [Token] = [.function, .identifier(name: "f"), .leftBracket]
        tokens += argumentTokens
        tokens += [.rightBracket, .colon]
        let storage = try Storage(tokens: tokens)
        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.arguments.count, 1)
            XCTAssertEqual(definition.arguments[0].label, nil)
            XCTAssertEqual(definition.arguments[0].name, "a")
            XCTAssertEqual(definition.arguments[0].type.name, "Int")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenFunctionWithTwoArgument_whenParse_thenParse() throws {
        var tokens: [Token] = [.function, .identifier(name: "f"), .leftBracket]
        tokens += argumentTokens
        tokens += [.comma]
        tokens += argumentTokens
        tokens += [.rightBracket, .colon]
        let storage = try Storage(tokens: tokens)

        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.arguments.count, 2)
            XCTAssertEqual(definition.arguments[1].label, nil)
            XCTAssertEqual(definition.arguments[1].name, "a")
            XCTAssertEqual(definition.arguments[1].type.name, "Int")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenFunctionWithThreeArgument_whenParse_thenParse() throws {
        var tokens: [Token] = [.function, .identifier(name: "f"), .leftBracket]
        tokens += argumentTokens
        tokens += [.comma]
        tokens += argumentTokens
        tokens += [.comma]
        tokens += argumentTokens
        tokens += [.rightBracket, .colon]
        let storage = try Storage(tokens: tokens)

        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.arguments.count, 3)
            XCTAssert(definition.returnType == nil)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenFunctionWithEmptyReturn_whenParse_thenThrowException() throws {
        let tokens: [Token] = [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .arrow]
        let storage = try Storage(tokens: tokens)

        testParserException(with: storage, .invalidReturnType)
        XCTAssertEqual(storage.current, .arrow)
    }

    func test_givenFunctionWithReturn_whenParse_thenReturnFunctionDeclaration() throws {
        let tokens: [Token] = [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .arrow, .identifier(name: "Int")]
        let storage = try Storage(tokens: tokens)

        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.arguments.count, 0)
            XCTAssertEqual(storage.current, .identifier(name: "Int"))
            XCTAssertEqual(definition.returnType?.name, "Int")
        } catch {
            XCTFail()
        }
    }

    func test_givenThrowingFunction_whenParse_thenFunctionParsed() throws {
        let storage = try Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .throws, .colon])
        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.isThrowing, true)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenThrowingFunctionWithReturn_whenParse_thenFunctionIsParsed() throws {
        let tokens: [Token] = [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .throws, .arrow, .identifier(name: "Int")]
        let storage = try Storage(tokens: tokens)

        do {
            let definition = try FunctionDeclarationParser(storage: storage).parse()
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(definition.arguments.count, 0)
            XCTAssertEqual(definition.isThrowing, true)
            XCTAssertEqual(definition.returnType?.name, "Int")
            XCTAssertEqual(storage.current, .identifier(name: "Int"))
        } catch {
            XCTFail()
        }
    }

    private func testParserException(with storage: Storage, _ exception: FunctionDeclarationParserError) {
        testException(with: exception, parse: {
            _ = try FunctionDeclarationParser(storage: storage).parse()
        })
    }
}
