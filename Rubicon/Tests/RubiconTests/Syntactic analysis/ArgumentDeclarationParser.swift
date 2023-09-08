@testable import Rubicon
import XCTest
import SwiftParser
import SwiftSyntax

final class ArgumentDeclarationParserTests: XCTestCase {
    private var typeDeclarationParserSpy: TypeDeclarationParserSpy!
    private var sut: ArgumentDeclarationParserImpl!

    override func setUp() {
        super.setUp()
        typeDeclarationParserSpy = TypeDeclarationParserSpy(parseReturn: .makeStub())
        sut = ArgumentDeclarationParserImpl(typeDeclarationParser: typeDeclarationParserSpy)
    }

    override func tearDown() {
        super.tearDown()
        typeDeclarationParserSpy = nil
        sut = nil
    }

    func test_givenArgument_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "label name: Type")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.label, "label")
        XCTAssertEqual(declaration.name, "name")
        XCTAssertEqual(declaration.type, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "Type")
    }

    func test_givenArgumentWithoutLabel_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "name: Type")

        let declaration = try sut.parse(node: node)

        XCTAssertEqual(declaration.label, nil)
        XCTAssertEqual(declaration.name, "name")
        XCTAssertEqual(declaration.type, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "Type")
    }

    func test_givenArgumentWithUnderscore_whenParse_thenReturnDeclaration() throws {
        let node = try parse(string: "_ name: Type")

        let declaration = try sut.parse(node: node)

        XCTAssertNil(declaration.label)
        XCTAssertEqual(declaration.name, "name")
        XCTAssertEqual(declaration.type, .makeStub())
        XCTAssertEqual(typeDeclarationParserSpy.parse.count, 1)
        XCTAssertEqual(typeDeclarationParserSpy.parse.first?.node.description, "Type")
    }


    private func parse(string: String) throws -> FunctionParameterSyntax {
        let file = SwiftParser.Parser.parse(source: "func (\(string))")
        guard let declaration =  file.statements.first?.item.as(FunctionDeclSyntax.self) else {
            throw TestsError.error
        }

        guard let parameter = declaration.signature.parameterClause.parameters.first else {
            throw TestsError.error
        }

        return parameter
    }
}

private enum TestsError: Error {
    case error
}
