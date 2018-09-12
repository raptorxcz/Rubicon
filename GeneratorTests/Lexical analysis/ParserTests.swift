//
//  ParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation
import Generator
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

    func test_givenHiddenKeyword_whenParse_thenIdentifierIsParsed() {
        let result = parser.parse("aaprotocolaas")
        XCTAssertEqual(result, [.identifier(name: "aaprotocolaas")])
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

    func test_givenProtocolWithUnderscore_whenParse_thenProtocolAndNameToken() {
        let result = parser.parse("protocol _")
        XCTAssertEqual(result, [.protocol, .identifier(name: "_")])
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
        XCTAssertEqual(result, [.constant, .identifier(name: "get")])
    }

    func test_givenSetWithName_whenParse_thenSetToken() {
        let result = parser.parse("let set")
        XCTAssertEqual(result, [.constant, .identifier(name: "set")])
    }

    func test_givenFuncWithName_whenParse_thenFuncToken() {
        let result = parser.parse("let func")
        XCTAssertEqual(result, [.constant, .function])
    }

    func test_givenArrowWithName_whenParse_thenArrowToken() {
        let result = parser.parse("let->:")
        XCTAssertEqual(result, [.constant, .arrow, .colon])
    }

    func test_givenKeyWordIdentifier_whenParse_thenIdentifierToken() {
        let result = parser.parse("let `protocol`:")
        XCTAssertEqual(result, [.constant, .identifier(name: "protocol"), .colon])
    }

    func test_givenLeftSquareBracket_whenParse_thenLeftSquareBracketIsParsed() {
        let result = parser.parse("[")
        XCTAssertEqual(result, [.leftSquareBracket])
    }

    func test_givenRightSquareBracket_whenParse_thenRightSquareBracketIsParsed() {
        let result = parser.parse("]")
        XCTAssertEqual(result, [.rightSquareBracket])
    }

    func test_givenThrowsKeyword_whenParse_thenThrowsKeywordIsParsed() {
        let result = parser.parse("] throws")
        XCTAssertEqual(result, [.rightSquareBracket, .throws])
    }

    func test_givenLessThen_whenParse_thenGreaterThenIsParser() {
        let result = parser.parse("< throws")
        XCTAssertEqual(result, [.lessThan, .throws])
    }

    func test_givenGreaterThen_whenParse_thenGreaterThenIsParser() {
        let result = parser.parse("> throws")
        XCTAssertEqual(result, [.greaterThan, .throws])
    }

    func test_givenIdenfierWithDotNotation_whenParse_thenIdentifierIsParsed() {
        let result = parser.parse("Insurance.Basics throws")
        XCTAssertEqual(result, [.identifier(name: "Insurance.Basics"), .throws])
    }

    func test_givenEscapingWithoutAt_whenParse_thenIdentifierIsParsed() {
        let result = parser.parse("escaping")
        XCTAssertEqual(result, [.identifier(name: "escaping")])
    }

    func test_givenEscaping_whenParse_thenEscapingIsParsed() {
        let result = parser.parse("@escaping")
        XCTAssertEqual(result, [.escaping])
    }

    func test_givenNameColonEscapingType_whenParse_thenIdentifierColonEscapingIdentifierIsParsed() {
        let result = parser.parse("name: @escaping Abc")
        XCTAssertEqual(result, [.identifier(name: "name"), .colon, .escaping, .identifier(name: "Abc")])
    }

    func test_givenAutoclosure_whenParse_thenAutoclosureIsParsed() {
        let result = parser.parse("@autoclosure")
        XCTAssertEqual(result, [.autoclosure])
    }

    func test_givenNameColonAutoclosureType_whenParse_thenIdentifierColonAutoclosureIdentifierIsParsed() {
        let result = parser.parse("name: @autoclosure Abc")
        XCTAssertEqual(result, [.identifier(name: "name"), .colon, .autoclosure, .identifier(name: "Abc")])
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
            .identifier(name: "get"),
            .identifier(name: "set"),
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
            .rightCurlyBracket,
        ]
        XCTAssertEqual(result, expected)
    }

    func test_givenBigFile_whenParse_thenMeasureSpeed() {
        let url = Bundle(for: ParserTests.self).url(forResource: "SampleProject", withExtension: "txt")!
        let string = try! String(contentsOf: url, encoding: .utf8)
        measure {
            _ = self.parser.parse(string)
        }
    }
}
