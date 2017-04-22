//
//  ParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {

    let parser = Parser()

    func test_givenEmptyString_whenParse_thenEmptyResult() {
        XCTAssert(parser.parse("") == [Token]())
    }

    func test_givenWhiteCharacters_whenParse_thenEmptyResult() {
        XCTAssert(parser.parse(" \t\n ") == [Token]())
    }

    func test_givenIdentifier_whenParse_thenIdentifierToken() {
        let result = parser.parse("a")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], .identifier(name: "a"))
    }

    func test_givenProtocol_whenParse_thenProtocolToken() {
        let result = parser.parse("protocol")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], .protocol)
    }

    func test_givenProtocolWithSpce_whenParse_thenProtocolToken() {
        let result = parser.parse("protocol \t")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], .protocol)
    }

    func test_givenProtocolTwice_whenParse_thenProtocolToken() {
        let result = parser.parse("protocol protocol")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .protocol)
        XCTAssertEqual(result[1], .protocol)
    }

    func test_givenProtocolWithWhiteCharacters_whenParse_thenProtocolToken() {
        let result = parser.parse(" \tprotocol\t ")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], .protocol)
    }

    func test_givenColon_whenParse_thenColonToken() {
        let result = parser.parse("protocol:")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .protocol)
        XCTAssertEqual(result[1], .colon)
    }

    func test_givenEqual_whenParse_thenEqualToken() {
        let result = parser.parse("protocol = ")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .protocol)
        XCTAssertEqual(result[1], .equal)
    }

    func test_givenLeftCurlyBracket_whenParse_thenleftCurlyBracketToken() {
        let result = parser.parse(":{")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .colon)
        XCTAssertEqual(result[1], .leftCurlyBracket)
    }

    func test_givenRightCurlyBracket_whenParse_thenRightCurlyBracketToken() {
        let result = parser.parse(":}")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .colon)
        XCTAssertEqual(result[1], .rightCurlyBracket)
    }

    func test_givenRightBracket_whenParse_thenRightBracketToken() {
        let result = parser.parse(":)")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .colon)
        XCTAssertEqual(result[1], .rightBracket)
    }

    func test_givenLeftBracket_whenParse_thenLeftBracketToken() {
        let result = parser.parse(":(")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .colon)
        XCTAssertEqual(result[1], .leftBracket)
    }

    func test_givenComma_whenParse_thenCommaToken() {
        let result = parser.parse(":,")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .colon)
        XCTAssertEqual(result[1], .comma)
    }

    func test_givenProtocolWithName_whenParse_thenProtocolAndNameToken() {
        let result = parser.parse("protocol test")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .protocol)
        XCTAssertEqual(result[1], .identifier(name: "test"))
    }

    func test_givenVarWithName_whenParse_thenVariableToken() {
        let result = parser.parse("var test")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .variable)
        XCTAssertEqual(result[1], .identifier(name: "test"))
    }

    func test_givenLetWithName_whenParse_thenConstantToken() {
        let result = parser.parse("let test")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .constant)
        XCTAssertEqual(result[1], .identifier(name: "test"))
    }

    func test_givenGetWithName_whenParse_thenGetToken() {
        let result = parser.parse("let get")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .constant)
        XCTAssertEqual(result[1], .get)
    }

    func test_givenSetWithName_whenParse_thenSetToken() {
        let result = parser.parse("let set")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .constant)
        XCTAssertEqual(result[1], .set)
    }

    func test_givenFuncWithName_whenParse_thenFuncToken() {
        let result = parser.parse("let func")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], .constant)
        XCTAssertEqual(result[1], .function)
    }

    func test_givenProtocolDefinition_whenParse_thenProtocolTokens() {
        var string = ""
        string += "protocol Satelite {\n"
        string += "    var panels: Int { get set }\n"
        string += "    func move(to x: Float, y: Float)\n"
        string += "}"

        let result = parser.parse(string)
        XCTAssertEqual(result.count, 24)
        XCTAssertEqual(result[0], .protocol)
        XCTAssertEqual(result[1], .identifier(name: "Satelite"))
        XCTAssertEqual(result[2], .leftCurlyBracket)
        XCTAssertEqual(result[3], .variable)
        XCTAssertEqual(result[4], .identifier(name: "panels"))
        XCTAssertEqual(result[5], .colon)
        XCTAssertEqual(result[6], .identifier(name: "Int"))
        XCTAssertEqual(result[7], .leftCurlyBracket)
        XCTAssertEqual(result[8], .get)
        XCTAssertEqual(result[9], .set)
        XCTAssertEqual(result[10], .rightCurlyBracket)
        XCTAssertEqual(result[11], .function)
        XCTAssertEqual(result[12], .identifier(name: "move"))
        XCTAssertEqual(result[13], .leftBracket)
        XCTAssertEqual(result[14], .identifier(name: "to"))
        XCTAssertEqual(result[15], .identifier(name: "x"))
        XCTAssertEqual(result[16], .colon)
        XCTAssertEqual(result[17], .identifier(name: "Float"))
        XCTAssertEqual(result[18], .comma)
        XCTAssertEqual(result[19], .identifier(name: "y"))
        XCTAssertEqual(result[20], .colon)
        XCTAssertEqual(result[21], .identifier(name: "Float"))
        XCTAssertEqual(result[22], .rightBracket)
        XCTAssertEqual(result[23], .rightCurlyBracket)
        XCTAssertEqual(result[8], .get)
        XCTAssertEqual(result[9], .set)
        XCTAssertEqual(result[10], .rightCurlyBracket)
        XCTAssertEqual(result[11], .function)
        XCTAssertEqual(result[12], .identifier(name: "move"))
    }

}
