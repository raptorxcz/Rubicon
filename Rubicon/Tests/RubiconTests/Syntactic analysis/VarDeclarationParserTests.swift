//
//  VarDeclarationTypeTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

@testable import Rubicon
import XCTest
import SwiftParser
import SwiftSyntax

final class VarDeclarationParserTests: XCTestCase {
    private var typeDeclarationParserSpy: TypeDeclarationParserSpy!
    private var sut: VarDeclarationParserImpl!

    override func setUp() {
        super.setUp()
        typeDeclarationParserSpy = TypeDeclarationParserSpy(parseReturn: .makeStub())
        sut = VarDeclarationParserImpl(typeDeclarationParser: typeDeclarationParserSpy)
    }

    override func tearDown() {
        super.tearDown()
        typeDeclarationParserSpy = nil
        sut = nil
    }

    func test_givenEmptyString_whenParse_thenThrowMissingDeclaration() {
        let node = parse(string: "")

        XCTAssertThrowsError(try sut.parse(node: node)) { error in
            XCTAssertEqual(error as? VarDeclarationError, .missingDeclaration)
        }
    }

    func test_givenValidDeclaration_whenParse_thenReturnType() throws {
        let node = parse(string: "let name: Type")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.identifier, "name")
        XCTAssertEqual(declaration.isConstant, true)
        XCTAssertEqual(declaration.type, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "Type")
    }

    private func parse(string: String) -> SyntaxProtocol {
        return SwiftParser.Parser.parse(source: string)
    }
}

final class TypeDeclarationParserSpy: TypeDeclarationParser {
    enum SpyError: Error {
        case spyError
    }
    typealias ThrowBlock = () throws -> Void

    struct Parse {
        let node: SyntaxProtocol
    }

    var parse = [Parse]()
    var parseThrowBlock: ThrowBlock?
    var parseReturn: TypeDeclaration

    init(parseReturn: TypeDeclaration) {
        self.parseReturn = parseReturn
    }

    func parse(node: some SyntaxProtocol) throws -> TypeDeclaration {
        let item = Parse(node: node)
        parse.append(item)
        try parseThrowBlock?()
        return parseReturn
    }
}
