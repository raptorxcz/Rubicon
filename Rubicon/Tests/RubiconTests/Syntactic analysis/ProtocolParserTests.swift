//
//  ProtocolParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

class ProtocolParserTests: XCTestCase {

    let parser = ProtocolParser()
    private let varTokens: [Token] = [.variable, .identifier(name: "a"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .rightCurlyBracket]
    private let funcTokens: [Token] = [.function, .identifier(name: "a"), .leftBracket, .rightBracket]

    func test_givenInvalidToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.colon])
        testParserException(with: storage, .invalidProtocolToken)
    }

    func test_givenInvalidNameToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.protocol, .colon])
        testParserException(with: storage, .invalidNameToken)
    }

    func test_givenInvalidLeftBracketToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .comma])
        testParserException(with: storage, .expectedLeftBracket)
    }

    func test_givenNoLeftBracketToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p")])
        testParserException(with: storage, .expectedLeftBracket)
    }

    func test_givenNoLeftBracketTokenToChildProtocol_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .colon, .identifier(name: "a")])
        testParserException(with: storage, .expectedLeftBracket)
    }

    func test_givenInvalidRightBracketToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .leftCurlyBracket, .colon])
        testParserException(with: storage, .expectedRightBracket)
    }

    func test_givenEmptyProtocol_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .leftCurlyBracket, .rightCurlyBracket])
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(storage.current, .rightCurlyBracket)
        } catch {
            XCTFail()
        }
    }

    func test_givenEmptyProtocolInText_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .leftCurlyBracket, .rightCurlyBracket, .colon])
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithParentSeparator_whenParse_thenMakeNewProtocol() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .colon, .leftCurlyBracket, .rightCurlyBracket, .colon])
        testParserException(with: storage, .expectedParentProtocol)
    }

    func test_givenProtocolWithMultipleParentSeparator_whenParse_thenMakeNewProtocol() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .colon, .identifier(name: "c"), .comma, .identifier(name: "c"), .comma, .leftCurlyBracket, .rightCurlyBracket, .colon])
        testParserException(with: storage, .expectedParentProtocol)
    }

    func test_givenClassProtocol_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .colon, .identifier(name: "class"), .leftCurlyBracket, .rightCurlyBracket])
        do {
            let protocolType = try parser.parse(storage: storage)
            XCTAssertEqual(protocolType.name, "p")
            XCTAssertEqual(protocolType.parents, ["class"])
            XCTAssertEqual(storage.current, .rightCurlyBracket)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithParents_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .colon, .identifier(name: "class"), .comma, .identifier(name: "a"), .leftCurlyBracket, .rightCurlyBracket])
        do {
            let protocolType = try parser.parse(storage: storage)
            XCTAssertEqual(protocolType.name, "p")
            XCTAssertEqual(protocolType.parents, ["class", "a"])
            XCTAssertEqual(storage.current, .rightCurlyBracket)
        } catch {
            XCTFail()
        }
    }

    func test_givenParentProtocols_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.protocol, .identifier(name: "p"), .colon, .identifier(name: "class"), .leftCurlyBracket, .rightCurlyBracket])
        do {
            let protocolType = try parser.parse(storage: storage)
            XCTAssertEqual(protocolType.name, "p")
            XCTAssertEqual(protocolType.parents, ["class"])
            XCTAssertEqual(storage.current, .rightCurlyBracket)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithVariable_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += varTokens
        tokens += [.rightCurlyBracket, .colon]
        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.variables.count, 1)
            XCTAssertEqual(`protocol`.variables[0].identifier, "a")
            XCTAssertEqual(`protocol`.variables[0].type.name, "Int")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithTwoVariables_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += varTokens
        tokens += varTokens
        tokens += [.rightCurlyBracket, .colon]

        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.variables.count, 2)
            XCTAssertEqual(`protocol`.variables[1].identifier, "a")
            XCTAssertEqual(`protocol`.variables[1].type.name, "Int")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithFunction_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += funcTokens
        tokens += [.rightCurlyBracket, .colon]

        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.functions.count, 1)
            XCTAssertEqual(`protocol`.functions[0].name, "a")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithSetterFunction_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += [.function, .identifier(name: "set"), .leftBracket, .rightBracket]
        tokens += [.rightCurlyBracket, .colon]

        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.functions.count, 1)
            XCTAssertEqual(`protocol`.functions[0].name, "set")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithGetterFunction_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += [.function, .identifier(name: "get"), .leftBracket, .rightBracket]
        tokens += [.rightCurlyBracket, .colon]

        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.functions.count, 1)
            XCTAssertEqual(`protocol`.functions[0].name, "get")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithTwoFunctions_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += funcTokens
        tokens += funcTokens
        tokens += [.rightCurlyBracket, .colon]

        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.functions.count, 2)
            XCTAssertEqual(`protocol`.functions[1].name, "a")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenProtocolWithFunctionsAndVariables_whenParse_thenParse() throws {
        var tokens: [Token] = [.protocol, .identifier(name: "p"), .leftCurlyBracket]

        tokens += funcTokens
        tokens += varTokens
        tokens += funcTokens
        tokens += varTokens
        tokens += varTokens
        tokens += funcTokens
        tokens += [.rightCurlyBracket, .colon]

        let storage = try Storage(tokens: tokens)
        do {
            let `protocol` = try parser.parse(storage: storage)
            XCTAssertEqual(`protocol`.name, "p")
            XCTAssertEqual(`protocol`.variables.count, 3)
            XCTAssertEqual(`protocol`.functions.count, 3)
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
