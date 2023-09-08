//
//  SimpleTypeParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

//import Rubicon
//import XCTest
//
//class SimpleTypeParserTests: XCTestCase {
//
//    func makeParser(storage: Storage) -> TypeDeclarationParser {
//        return TypeDeclarationParser(storage: storage)
//    }
//
//    func test_givenColonToken_whenParse_thenThrowException() throws {
//        let storage = try Storage(tokens: [.colon])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.invalidName) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenNameToken_whenParse_thenParse() throws {
//        let storage = try Storage(tokens: [.identifier(name: "x")])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "x")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenNameColonTokens_whenParse_thenParse() throws {
//        let storage = try Storage(tokens: [.identifier(name: "x"), .colon])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "x")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .colon)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenSomeNameColonTokens_whenParse_thenParse() throws {
//        let storage = try Storage(tokens: [.some, .identifier(name: "x"), .colon])
//        let parser = makeParser(storage: storage)
//
//        let type = try parser.parse()
//
//        XCTAssertEqual(type.name, "x")
//        XCTAssertEqual(type.isOptional, false)
//        XCTAssertEqual(type.isClosure, false)
//        XCTAssertNil(type.prefix)
//        XCTAssertEqual(storage.current, .colon)
//        XCTAssertEqual(type.existencial, "some")
//    }
//
//    func test_givenAnyNameColonTokens_whenParse_thenParse() throws {
//        let storage = try Storage(tokens: [.some, .identifier(name: "x"), .colon])
//        let parser = makeParser(storage: storage)
//
//        let type = try parser.parse()
//
//        XCTAssertEqual(type.name, "x")
//        XCTAssertEqual(type.isOptional, false)
//        XCTAssertEqual(type.isClosure, false)
//        XCTAssertNil(type.prefix)
//        XCTAssertEqual(storage.current, .colon)
//        XCTAssertEqual(type.existencial, "some")
//    }
//
//    func test_givenNameQuestionMarkTokens_whenParse_thenParse() throws {
//        let storage = try Storage(tokens: [.identifier(name: "x"), .questionMark, .colon])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "x")
//            XCTAssertEqual(type.isOptional, true)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .colon)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenArrayTypeWithInvalidName_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .arrow, .identifier(name: "A"), .colon])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.invalidName) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenArrayTypeWithoutEndingBracket_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "A"), .arrow])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.missingEndingBracket) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenArrayType_whenParse_thenArrayIsParsed() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "x"), .rightSquareBracket, .colon])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "[x]")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .colon)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenOptionalArrayType_whenParse_thenArrayIsParsed() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "x"), .questionMark, .rightSquareBracket, .questionMark, .colon])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "[x?]")
//            XCTAssertEqual(type.isOptional, true)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .colon)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenDictionaryTypeWithInvalidValueName_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "s"), .colon, .arrow, .identifier(name: "A"), .colon])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.invalidName) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenDictionaryWithoutEndingBracket_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "s"), .colon, .identifier(name: "A"), .colon])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.missingEndingBracket) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenDictionary_whenParse_thenDictionaryIsParsed() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "s"), .colon, .identifier(name: "A"), .rightSquareBracket, .arrow])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "[s: A]")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .arrow)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenOptionalDictionary_whenParse_thenDictionaryIsParsed() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "s"), .colon, .identifier(name: "A"), .questionMark, .rightSquareBracket, .questionMark, .arrow])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "[s: A?]")
//            XCTAssertEqual(type.isOptional, true)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .arrow)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenMultiArrayType_whenParse_thenArrayIsParsed() throws {
//        let storage = try Storage(tokens: [.leftSquareBracket, .leftSquareBracket, .identifier(name: "x"), .rightSquareBracket, .rightSquareBracket, .colon])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "[[x]]")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .colon)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenGenericTypeWithoutSubtype_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .arrow])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.missingIdentifier) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenGenericTypeWithoutEndingBracket_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .identifier(name: "B"), .arrow])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.missingEndingGreaterThan) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenGenericType_whenParse_thenTypeIsParsed() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .identifier(name: "B"), .greaterThan, .arrow])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "A<B>")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .arrow)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenComplexGenericType_whenParse_thenTypeIsParsed() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .identifier(name: "B"), .lessThan, .identifier(name: "C"), .greaterThan, .greaterThan, .arrow])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "A<B<C>>")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .arrow)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func test_givenIncompleGenericType_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .identifier(name: "C"), .comma, .arrow])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.missingIdentifier) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenGenericTypeWithMultipleSubtypesWithoutEndingBracket_whenParse_thenExceptionIsThrown() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .identifier(name: "C"), .comma, .identifier(name: "D"), .arrow])
//        let parser = makeParser(storage: storage)
//
//        testException(with: SimpleTypeParserError.missingEndingGreaterThan) {
//            _ = try parser.parse()
//        }
//    }
//
//    func test_givenGenericTypeWithMultipleSubtypes_whenParse_thenTypeIsParsed() throws {
//        let storage = try Storage(tokens: [.identifier(name: "A"), .lessThan, .identifier(name: "C"), .comma, .identifier(name: "D"), .greaterThan, .arrow])
//        let parser = makeParser(storage: storage)
//
//        do {
//            let type = try parser.parse()
//            XCTAssertEqual(type.name, "A<C, D>")
//            XCTAssertEqual(type.isOptional, false)
//            XCTAssertEqual(type.isClosure, false)
//            XCTAssertNil(type.prefix)
//            XCTAssertEqual(storage.current, .arrow)
//        } catch {
//            XCTFail()
//        }
//    }
//}
