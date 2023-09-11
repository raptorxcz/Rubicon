//
//  FunctionDeclarationParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

@testable import Rubicon
import SwiftParser
import SwiftSyntax
import XCTest

final class FunctionDeclarationParserTests: XCTestCase {
    private var typeDeclarationParserSpy: TypeDeclarationParserSpy!
    private var argumentDeclarationParserSpy: ArgumentDeclarationParserSpy!
    private var sut: FunctionDeclarationParserImpl!

    override func setUp() {
        super.setUp()
        typeDeclarationParserSpy = TypeDeclarationParserSpy(parseReturn: .makeStub())
        argumentDeclarationParserSpy = ArgumentDeclarationParserSpy(parseReturn: .makeStub())
        sut = FunctionDeclarationParserImpl(
            typeDeclarationParser: typeDeclarationParserSpy,
            argumentDeclarationParser: argumentDeclarationParserSpy
        )
    }

    override func tearDown() {
        super.tearDown()
        typeDeclarationParserSpy = nil
        sut = nil
    }

    func test_givenFunction_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "func name()")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "name")
        XCTAssertEqual(declaration.arguments.count, 0)
        XCTAssertEqual(declaration.isAsync, false)
        XCTAssertEqual(declaration.isThrowing, false)
        XCTAssertNil(declaration.returnType)
    }

    func test_givenFunctionWithArguments_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "func name(a: B)")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.arguments.count, 1)
        XCTAssertEqual(declaration.arguments.first, .makeStub())
        XCTAssertEqual(argumentDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(argumentDeclarationParserSpy.parse.first?.node.description, "a: B")
    }

    func test_givenThrowingFunction_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "func name() throws")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.isThrowing, true)
    }

    func test_givenAsyncFunction_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "func name() async")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.isAsync, true)
    }

    func test_givenFunctionWithResult_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "func name() -> C")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.returnType, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "C")
    }

    private func parse(string: String) throws -> FunctionDeclSyntax {
        let string = """
        protocol X {
            \(string)
        }
        """

        let file = SwiftParser.Parser.parse(source: string)
        guard let protocolDeclaration = file.statements.first?.item.as(ProtocolDeclSyntax.self) else {
            throw TestsError.error
        }

        guard let functionDeclaration = protocolDeclaration.memberBlock.members.first?.decl.as(FunctionDeclSyntax.self) else {
            throw TestsError.error
        }

        return functionDeclaration
    }
}

private enum TestsError: Error {
    case error
}

final class ArgumentDeclarationParserSpy: ArgumentDeclarationParser {
    struct Parse {
        let node: FunctionParameterSyntax
    }

    var parse = [Parse]()
    var parseReturn: ArgumentDeclaration

    init(parseReturn: ArgumentDeclaration) {
        self.parseReturn = parseReturn
    }

    func parse(node: FunctionParameterSyntax) -> ArgumentDeclaration {
        let item = Parse(node: node)
        parse.append(item)
        return parseReturn
    }
}

extension ArgumentDeclaration {
    static func makeStub(
        label: String? = "label",
        name: String = "name",
        type: TypeDeclaration = .makeStub()
    ) -> ArgumentDeclaration {
        return ArgumentDeclaration(
            label: label,
            name: name,
            type: type
        )
    }
}
