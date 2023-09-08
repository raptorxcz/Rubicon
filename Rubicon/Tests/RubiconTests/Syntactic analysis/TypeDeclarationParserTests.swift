//
//  File.swift
//  
//
//  Created by Kryštof Matěj on 08.09.2023.
//

@testable import Rubicon
import XCTest
import SwiftParser
import SwiftSyntax

final class TypeDeclarationParserTests: XCTestCase {
    var sut: TypeDeclarationParserImpl!

    override func setUp() {
        super.setUp()
        sut = TypeDeclarationParserImpl()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func test_givenEmptyString_whenParse_thenThrowError() {
        let node = parse(string: "")

        XCTAssertThrowsError(try sut.parse(node: node)) { error in
            XCTAssertEqual(error as? TypeDeclarationParserError, .missingDeclaration)
        }
    }

    func test_givenSimpleType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "T")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "T")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenOptionalType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "T?")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "T?")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, true)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenForcedUpwrappedType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "T!")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "T!")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenClosure_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "() -> Void")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "() -> Void")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenOptionalClosure_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "() -> Void?")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "() -> Void?")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, true)
        XCTAssertNil(declaration.prefix)
    }

// TODO: not working, question is, is it swift parser error?
//    func test_givenSomeType_whenParse_thenReturnDeclaration() throws {
//        let node = parse(string: "some T")
//
//        let declaration = try sut.parse(node: node)
//
//        XCTAssertEqual(declaration.name, "some T")
//        XCTAssertEqual(declaration.isClosure, false)
//        XCTAssertEqual(declaration.isOptional, false)
//        XCTAssertNil(declaration.prefix)
//    }

    func test_givenAnyType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "any T")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "any T")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenDictionaryType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "[A: B]")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "[A: B]")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenGenericType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "A<B>")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "A<B>")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertNil(declaration.prefix)
    }

    func test_givenOptionalGenericType_whenParse_thenReturnDeclaration() throws {
        let node = parse(string: "A<B>?")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.name, "A<B>?")
        XCTAssertEqual(declaration.isClosure, false)
        XCTAssertEqual(declaration.isOptional, true)
        XCTAssertNil(declaration.prefix)
    }

    private func parse(string: String) -> SyntaxProtocol {
        return SwiftParser.Parser.parse(source: string)
    }
}

