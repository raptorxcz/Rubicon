@testable import Rubicon
import SwiftParser
import SwiftSyntax
import XCTest

final class ProtocolParserTests: XCTestCase {
    private var functionParserSpy: FunctionDeclarationParserSpy!
    private var varParserSpy: VarDeclarationParserSpy!
    private var sut: ProtocolParserImpl!

    override func setUp() {
        super.setUp()
        functionParserSpy = FunctionDeclarationParserSpy(parseReturn: .makeStub())
        varParserSpy = VarDeclarationParserSpy(parseReturn: .makeStub())
        sut = ProtocolParserImpl(
            functionParser: functionParserSpy,
            varParser: varParserSpy
        )
    }

    func test_givenNoProtocol_whenParse_thenReturnEmptyResult() throws {
        let text = """
        """

        let protocols = try sut.parse(text: text)

        XCTAssertEqual(protocols.count, 0)
    }

    func test_givenEmptyProtocol_whenParse_thenReturnProtocol() throws {
        let text = """
        protocol A {
        }
        """

        let protocols = try sut.parse(text: text)

        XCTAssertEqual(protocols.count, 1)
        XCTAssertEqual(protocols.first?.name, "A")
        XCTAssertEqual(protocols.first?.parents.count, 0)
        XCTAssertEqual(protocols.first?.functions.count, 0)
        XCTAssertEqual(protocols.first?.variables.count, 0)
    }

    func test_givenProtocolWithFunctions_whenParse_thenReturnProtocol() throws {
        let text = """
        protocol A {
            func a()
        }
        """

        let protocols = try sut.parse(text: text)

        XCTAssertEqual(protocols.count, 1)
        XCTAssertEqual(protocols.first?.name, "A")
        XCTAssertEqual(protocols.first?.parents.count, 0)
        XCTAssertEqual(protocols.first?.functions.count, 1)
        XCTAssertEqual(protocols.first?.functions.first, .makeStub())
        XCTAssertEqual(protocols.first?.variables.count, 0)
        XCTAssertEqual(functionParserSpy.parse.count, 1)
        XCTAssertEqual(functionParserSpy.parse.first?.node.description, "\n    func a()")
    }

    func test_givenProtocolWithVariables_whenParse_thenReturnProtocol() throws {
        let text = """
        protocol A {
            var a: Int { get set }
            var b: Int { get }
        }
        """

        let protocols = try sut.parse(text: text)

        XCTAssertEqual(protocols.count, 1)
        XCTAssertEqual(protocols.first?.name, "A")
        XCTAssertEqual(protocols.first?.parents.count, 0)
        XCTAssertEqual(protocols.first?.functions.count, 0)
        XCTAssertEqual(protocols.first?.variables.count, 2)
        XCTAssertEqual(protocols.first?.variables.first, .makeStub())
        XCTAssertEqual(varParserSpy.parse.count, 2)
        XCTAssertEqual(varParserSpy.parse.first?.node.description, "\n    var a: Int { get set }")
    }
}

final class FunctionDeclarationParserSpy: FunctionDeclarationParser {
    struct Parse {
        let node: FunctionDeclSyntax
    }

    var parse = [Parse]()
    var parseReturn: FunctionDeclaration

    init(parseReturn: FunctionDeclaration) {
        self.parseReturn = parseReturn
    }

    func parse(node: FunctionDeclSyntax) -> FunctionDeclaration {
        let item = Parse(node: node)
        parse.append(item)
        return parseReturn
    }
}

extension FunctionDeclaration {
    static func makeStub(
        name: String = "name",
        arguments: [ArgumentDeclaration] = [],
        isThrowing: Bool = false,
        isAsync: Bool = false,
        returnType: TypeDeclaration? = nil
    ) -> FunctionDeclaration {
        return FunctionDeclaration(
            name: name,
            arguments: arguments,
            isThrowing: isThrowing,
            isAsync: isAsync,
            returnType: returnType
        )
    }
}

final class VarDeclarationParserSpy: VarDeclarationParser {
    enum SpyError: Error {
        case spyError
    }

    typealias ThrowBlock = () throws -> Void

    struct Parse {
        let node: VariableDeclSyntax
    }

    var parse = [Parse]()
    var parseThrowBlock: ThrowBlock?
    var parseReturn: VarDeclaration

    init(parseReturn: VarDeclaration) {
        self.parseReturn = parseReturn
    }

    func parse(node: VariableDeclSyntax) throws -> VarDeclaration {
        let item = Parse(node: node)
        parse.append(item)
        try parseThrowBlock?()
        return parseReturn
    }
}

extension VarDeclaration {
    static func makeStub(
        isConstant: Bool = false,
        identifier: String = "identifier",
        type: TypeDeclaration = .makeStub()
    ) -> VarDeclaration {
        return VarDeclaration(
            isConstant: isConstant,
            identifier: identifier,
            type: type
        )
    }
}
