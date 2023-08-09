//
//  VarDeclarationTypeTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

class VarDeclarationTypeParserTests: XCTestCase {

    let parser = VarDeclarationTypeParser()

    func test_givenVariableToken_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            return
        }

        XCTFail()
    }

    func test_givenMissingColonToken_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .identifier(name: "Int")])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
            XCTAssertEqual(storage.current, .variable)
        } catch {
            return
        }

        XCTFail()
    }

    func test_givenInvalidTokens1_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.constant, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .rightCurlyBracket])
        do {

            _ = try parser.parse(storage: storage)
        } catch {
            return
        }

        XCTFail()
    }

    func test_givenInvalidTokens2_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "Int"), .variable, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .rightCurlyBracket])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            return
        }

        XCTFail()
    }

    func test_givenInvalidTokens3_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "Int"), .colon, .identifier(name: "Int"), .variable, .identifier(name: "get"), .rightCurlyBracket])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            XCTAssertEqual(storage.current, .variable)
            return
        }

        XCTFail()
    }

    func test_givenInvalidType_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "Int"), .colon, .colon, .variable, .identifier(name: "get"), .rightCurlyBracket])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            XCTAssertEqual(storage.current, .variable)
            return
        }

        XCTFail()
    }

    func test_givenInvalidTokens4_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "Int"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .variable])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            return
        }

        XCTFail()
    }

    func test_givenInvalidEndingBracket_whenParse_thenThrowError() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "Int"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .identifier(name: "set"), .colon])
        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            XCTAssertEqual(storage.current, .variable)
            return
        }

        XCTFail()
    }

    func test_givenConstantDefinition_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertNil(type.prefix)
            XCTAssertEqual(type.isConstant, true)
            XCTAssertEqual(type.identifier, "x")
            XCTAssertEqual(type.type.name, "Int")
        } catch {
            XCTFail()
        }
    }

    func test_givenSomeConstantDefinition_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.some, .variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.prefix, "some")
        } catch {
            XCTFail()
        }
    }

    func test_givenAnyConstantDefinition_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.any, .variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.prefix, "any")
        } catch {
            XCTFail()
        }
    }

    func test_givenVariableDefinition_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "get"), .identifier(name: "set"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.isConstant, false)
            XCTAssertEqual(type.identifier, "x")
            XCTAssertEqual(type.type.name, "Int")
            XCTAssertEqual(type.type.isOptional, false)
        } catch {
            XCTFail()
        }
    }

    func test_givenVariableDefinition2_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "set"), .identifier(name: "get"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.isConstant, false)
            XCTAssertEqual(type.identifier, "x")
            XCTAssertEqual(type.type.name, "Int")
            XCTAssertEqual(type.type.isOptional, false)
        } catch {
            XCTFail()
        }
    }

    func test_givenVariableDefinitionWithoutGet_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .leftCurlyBracket, .identifier(name: "set"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            _ = try parser.parse(storage: storage)
        } catch {
            return
        }
        XCTFail()
    }

    func test_givenOptionVariableDefinition_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .questionMark, .leftCurlyBracket, .identifier(name: "set"), .identifier(name: "get"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.isConstant, false)
            XCTAssertEqual(type.identifier, "x")
            XCTAssertEqual(type.type.name, "Int")
            XCTAssertEqual(type.type.isOptional, true)
        } catch {
            XCTFail()
        }
    }

    func test_givenAlotOfTokensDefinition_whenParse_thenParseVariable() throws {
        let storage = try Storage(tokens: [.variable, .identifier(name: "x"), .colon, .identifier(name: "Int"), .questionMark, .leftCurlyBracket, .identifier(name: "set"), .identifier(name: "get"), .rightCurlyBracket, .leftCurlyBracket, .identifier(name: "set"), .identifier(name: "get"), .rightCurlyBracket])

        do {
            let parser = VarDeclarationTypeParser()
            let type = try parser.parse(storage: storage)
            XCTAssertEqual(type.isConstant, false)
            XCTAssertEqual(type.identifier, "x")
            XCTAssertEqual(type.type.name, "Int")
            XCTAssertEqual(type.type.isOptional, true)
            XCTAssertEqual(storage.current, .leftCurlyBracket)
        } catch {
            XCTFail()
        }
    }
}
