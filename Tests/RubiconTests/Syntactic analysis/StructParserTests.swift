@testable import Rubicon
import SwiftParser
import SwiftSyntax
import XCTest

final class StructParserTests: XCTestCase {
    private var varParserSpy: VarDeclarationParserSpy!
    private var sut: StructParserImpl!

    override func setUp() {
        super.setUp()
        varParserSpy = VarDeclarationParserSpy(parseReturn: .makeStub())
        sut = StructParserImpl(
            varParser: varParserSpy
        )
    }

    func test_givenNoStruct_whenParse_thenReturnEmptyResult() throws {
        let text = """
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 0)
    }

    func test_givenEmptyStruct_whenParse_thenReturnStruct() throws {
        let text = """
        struct A {
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "A")
        XCTAssertEqual(structs.first?.variables.count, 0)
    }

    func test_givenStructWithVariables_whenParse_thenReturnStruct() throws {
        let text = """
        struct A {
            var a: Int
            let b: Int
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "A")
        XCTAssertEqual(structs.first?.variables.count, 2)
        XCTAssertEqual(structs.first?.variables.first, .makeStub())
        XCTAssertEqual(varParserSpy.parse.count, 2)
        XCTAssertEqual(varParserSpy.parse.first?.node.description, "\n    var a: Int")
    }
}
