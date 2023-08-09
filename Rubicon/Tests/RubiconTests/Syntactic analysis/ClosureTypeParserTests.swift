//
//  ClosureTypeParserTests.swift
//  GeneratorTests
//
//  Created by Jan Halousek on 10.09.18.
//  Copyright © 2018 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

class ClosureTypeParserTests: XCTestCase {

    private func makeParser(storage: Storage) -> TypeParser {
        return TypeParser(storage: storage)
    }

    func test_givenClosureType_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.leftBracket, .identifier(name: "A"), .rightBracket, .arrow, .identifier(name: "B"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "(A) -> B")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertNil(type.prefix)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenClosureTypeWithMultipleParameters_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.leftBracket, .identifier(name: "A"), .comma, .identifier(name: "B"), .rightBracket, .arrow, .identifier(name: "C"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "(A, B) -> C")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertNil(type.prefix)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenEscapingClosure_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.escaping, .leftBracket, .identifier(name: "A"), .rightBracket, .arrow, .identifier(name: "C"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "(A) -> C")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertEqual(type.prefix, .escaping)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenAutoclosureClosure_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.autoclosure, .leftBracket, .identifier(name: "A"), .rightBracket, .arrow, .identifier(name: "C"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "(A) -> C")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertEqual(type.prefix, .autoclosure)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenThrowingClosure_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.autoclosure, .leftBracket, .identifier(name: "A"), .rightBracket, .throws, .arrow, .identifier(name: "C"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "(A) throws -> C")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertEqual(type.prefix, .autoclosure)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenOptionalClosureType_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.leftBracket, .leftBracket, .identifier(name: "A"), .rightBracket, .arrow, .identifier(name: "B"), .rightBracket, .questionMark, .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "((A) -> B)")
            XCTAssertEqual(type.isOptional, true)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertNil(type.prefix)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenOptionalClosureOptionalParameterOptionalReturnType_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.leftBracket, .leftBracket, .identifier(name: "A"), .questionMark, .rightBracket, .arrow, .identifier(name: "B"), .questionMark, .rightBracket, .questionMark, .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "((A?) -> B?)")
            XCTAssertEqual(type.isOptional, true)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertNil(type.prefix)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenEmptyParametersClosureType_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.leftBracket, .rightBracket, .arrow, .identifier(name: "Void"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "() -> Void")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertNil(type.prefix)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenEscapingType_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.escaping, .identifier(name: "ActionBlock"), .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "ActionBlock")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertEqual(type.prefix, .escaping)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenComplexType_whenParse_thenTypeParsed() throws {
        let storage = try Storage(tokens: [.autoclosure, .leftBracket, .leftBracket,
                                           .leftSquareBracket, .identifier(name: "A"), .colon, .identifier(name: "B"), .rightSquareBracket, .comma,
                                           .leftSquareBracket, .identifier(name: "C"), .questionMark, .rightSquareBracket, .questionMark,
                                           .rightBracket, .arrow,
                                           .identifier(name: "Result"), .lessThan, .identifier(name: "D"), .greaterThan, .rightBracket, .comma])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "([A: B], [C?]?) -> Result<D>")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(type.isClosure, true)
            XCTAssertEqual(type.prefix, .autoclosure)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }
}
