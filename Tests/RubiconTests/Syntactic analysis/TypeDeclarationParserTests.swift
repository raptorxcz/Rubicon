@testable import Rubicon
import SwiftParser
import SwiftSyntax
import XCTest

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

    func test_givenSimpleType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "T ")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "T")
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertEqual(declaration.prefix, [])
    }

    func test_givenOptionalType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "T?")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "T?")
        XCTAssertEqual(declaration.isOptional, true)
    }

    func test_givenForcedUpwrappedType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "T!")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "T!")
        XCTAssertEqual(declaration.isOptional, false)
    }

    func test_givenClosure_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "() -> Void")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "() -> Void")
        XCTAssertEqual(declaration.isOptional, false)
    }

    func test_givenOptionalClosure_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "() -> Void?")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "() -> Void?")
        XCTAssertEqual(declaration.isOptional, true)
    }

    func test_givenSomeType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "some T")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "some T")
        XCTAssertEqual(declaration.isOptional, false)
    }

    func test_givenAnyType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "any T")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "any T")
        XCTAssertEqual(declaration.isOptional, false)
    }

    func test_givenDictionaryType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "[A: B]")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "[A: B]")
        XCTAssertEqual(declaration.isOptional, false)
    }

    func test_givenGenericType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "A<B>")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "A<B>")
        XCTAssertEqual(declaration.isOptional, false)
    }

    func test_givenOptionalGenericType_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "A<B>?")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "A<B>?")
        XCTAssertEqual(declaration.isOptional, true)
    }

    func test_givenEscapingClosure_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "@escaping Block")

        let declaration = sut.parse(node: node)

        XCTAssertEqual(declaration.name, "Block")
        XCTAssertEqual(declaration.isOptional, false)
        XCTAssertEqual(declaration.prefix, [.escaping])
    }

    private func parse(string: String) throws -> TypeSyntax {
        let file = SwiftParser.Parser.parse(source: "let v: " + string)

        guard let variableDeclaration = file.statements.first?.item.as(VariableDeclSyntax.self) else {
            throw TestsError.error
        }

        guard let typeDeclaration = variableDeclaration.bindings.first?.typeAnnotation?.type else {
            throw TestsError.error
        }

        return typeDeclaration
    }
}

private enum TestsError: Error {
    case error
}
