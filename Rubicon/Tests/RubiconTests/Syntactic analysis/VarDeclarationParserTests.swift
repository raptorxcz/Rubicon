//
//  VarDeclarationTypeTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

@testable import Rubicon
import SwiftParser
import SwiftSyntax
import XCTest

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

    func test_givenVariable_whenParse_thenReturnType() throws {
        let node = try parse(string: "var name: Type")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.identifier, "name")
        XCTAssertEqual(declaration.isConstant, false)
        XCTAssertEqual(declaration.type, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "Type")
    }

    func test_givenConstant_whenParse_thenReturnType() throws {
        let node = try parse(string: "let name: Type")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.identifier, "name")
        XCTAssertEqual(declaration.isConstant, true)
        XCTAssertEqual(declaration.type, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "Type")
    }

    private func parse(string: String) throws -> VariableDeclSyntax {
        let string = """
        protocol X {
            \(string)
        }
        """
        let file = SwiftParser.Parser.parse(source: string)
        guard let protocolDeclaration = file.statements.first?.item.as(ProtocolDeclSyntax.self) else {
            throw TestsError.error
        }
        guard let varDeclaration = protocolDeclaration.memberBlock.members.first?.decl.as(VariableDeclSyntax.self) else {
            throw TestsError.error
        }

        return varDeclaration
    }
}

final class TypeDeclarationParserSpy: TypeDeclarationParser {
    struct Parse {
        let node: TypeSyntax
    }

    var parse = [Parse]()
    var parseReturn: TypeDeclaration

    init(parseReturn: TypeDeclaration) {
        self.parseReturn = parseReturn
    }

    func parse(node: TypeSyntax) -> TypeDeclaration {
        let item = Parse(node: node)
        parse.append(item)
        return parseReturn
    }
}

private enum TestsError: Error {
    case error
}
