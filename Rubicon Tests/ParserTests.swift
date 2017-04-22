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
        XCTAssertEqual(result, [.identifier(name: "a")])
    }

    func test_givenProtocol_whenParse_thenProtocolToken() {
        let result = parser.parse("protocol")
        XCTAssertEqual(result, [.protocol])
    }

    func test_givenProtocolWithSpce_whenParse_thenProtocolToken() {
        let result = parser.parse("protocol \t")
        XCTAssertEqual(result, [.protocol])
    }

    func test_givenProtocolTwice_whenParse_thenProtocolToken() {
        let result = parser.parse("protocol protocol")
        XCTAssertEqual(result, [.protocol, .protocol])
    }

    func test_givenProtocolWithWhiteCharacters_whenParse_thenProtocolToken() {
        let result = parser.parse(" \tprotocol\t ")
        XCTAssertEqual(result, [.protocol])
    }

    func test_givenColon_whenParse_thenColonToken() {
        let result = parser.parse("protocol:")
        XCTAssertEqual(result, [.protocol, .colon])
    }

    func test_givenEqual_whenParse_thenEqualToken() {
        let result = parser.parse("protocol = ")
        XCTAssertEqual(result, [.protocol, .equal])
    }

    func test_givenLeftCurlyBracket_whenParse_thenleftCurlyBracketToken() {
        let result = parser.parse(":{")
        XCTAssertEqual(result, [.colon, .leftCurlyBracket])
    }

    func test_givenRightCurlyBracket_whenParse_thenRightCurlyBracketToken() {
        let result = parser.parse(":}")
        XCTAssertEqual(result, [.colon, .rightCurlyBracket])
    }

    func test_givenRightBracket_whenParse_thenRightBracketToken() {
        let result = parser.parse(":)")
        XCTAssertEqual(result, [.colon, .rightBracket])
    }

    func test_givenLeftBracket_whenParse_thenLeftBracketToken() {
        let result = parser.parse(":(")
        XCTAssertEqual(result, [.colon, .leftBracket])
    }

    func test_givenQuestionMark_whenParse_thenQuestionMarkToken() {
        let result = parser.parse(":?")
        XCTAssertEqual(result, [.colon, .questionMark])
    }

    func test_givenComma_whenParse_thenCommaToken() {
        let result = parser.parse(":,")
        XCTAssertEqual(result, [.colon, .comma])
    }

    func test_givenProtocolWithName_whenParse_thenProtocolAndNameToken() {
        let result = parser.parse("protocol test")
        XCTAssertEqual(result, [.protocol, .identifier(name: "test")])
    }

    func test_givenVarWithName_whenParse_thenVariableToken() {
        let result = parser.parse("var test")
        XCTAssertEqual(result, [.variable, .identifier(name: "test")])
    }

    func test_givenLetWithName_whenParse_thenConstantToken() {
        let result = parser.parse("let test")
        XCTAssertEqual(result, [.constant, .identifier(name: "test")])
    }

    func test_givenGetWithName_whenParse_thenGetToken() {
        let result = parser.parse("let get")
        XCTAssertEqual(result, [.constant, .get])
    }

    func test_givenSetWithName_whenParse_thenSetToken() {
        let result = parser.parse("let set")
        XCTAssertEqual(result, [.constant, .set])
    }

    func test_givenFuncWithName_whenParse_thenFuncToken() {
        let result = parser.parse("let func")
        XCTAssertEqual(result, [.constant, .function])
    }

    func test_givenProtocolDefinition_whenParse_thenProtocolTokens() {
        var string = ""
        string += "protocol Satelite {\n"
        string += "    var panels: Int { get set }\n"
        string += "    func move(to x: Float, y: Float)\n"
        string += "}"

        let result = parser.parse(string)
        let expected: [Token] = [
            .protocol,
            .identifier(name: "Satelite"),
            .leftCurlyBracket,
            .variable,
            .identifier(name: "panels"),
            .colon,
            .identifier(name: "Int"),
            .leftCurlyBracket,
            .get,
            .set,
            .rightCurlyBracket,
            .function,
            .identifier(name: "move"),
            .leftBracket,
            .identifier(name: "to"),
            .identifier(name: "x"),
            .colon,
            .identifier(name: "Float"),
            .comma,
            .identifier(name: "y"),
            .colon,
            .identifier(name: "Float"),
            .rightBracket,
            .rightCurlyBracket
        ]
        XCTAssertEqual(result, expected)
    }

}
