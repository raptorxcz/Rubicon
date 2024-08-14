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
        XCTAssertEqual(structs.first?.notes, [])
        XCTAssertEqual(structs.first?.accessLevel, .internal)
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

    func test_givenStructNestedInClass_whenParse_thenReturnStruct() throws {
        let text = """
        class B {
            struct A {
            }
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "B.A")
        XCTAssertEqual(structs.first?.variables.count, 0)
    }

    func test_givenStructNestedInEnum_whenParse_thenReturnStruct() throws {
        let text = """
        enum B {
            struct A {
            }
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "B.A")
        XCTAssertEqual(structs.first?.variables.count, 0)
    }

    func test_givenStructNestedInStruct_whenParse_thenReturnStruct() throws {
        let text = """
        struct B {
            struct A {
            }
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 2)
        XCTAssertEqual(structs.first?.name, "B")
        XCTAssertEqual(structs.first?.variables.count, 0)
        XCTAssertEqual(structs.last?.name, "B.A")
        XCTAssertEqual(structs.last?.variables.count, 0)
    }

    func test_givenStructNestedMultipleItems_whenParse_thenReturnStruct() throws {
        let text = """
        class B {
            enum C {
                struct D {
                    struct A {
                    }
                }
            }
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 2)
        XCTAssertEqual(structs.first?.name, "B.C.D")
        XCTAssertEqual(structs.first?.variables.count, 0)
        XCTAssertEqual(structs.last?.name, "B.C.D.A")
    }

    func test_givenEmptyWithNote_whenParse_thenReturnStruct() throws {
        let text = """
        // NOTE
        struct A {
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "A")
        XCTAssertEqual(structs.first?.variables.count, 0)
        XCTAssertEqual(structs.first?.notes, ["// NOTE"])
    }

    func test_givenPublicStruct_whenParse_thenReturnStruct() throws {
        let text = """
        public struct A {
        }
        """

        let structs = try sut.parse(text: text)


        XCTAssertEqual(structs.first?.accessLevel, .public)
    }

    func test_givenPrivateStruct_whenParse_thenReturnStruct() throws {
        let text = """
        private struct A {
        }
        """

        let structs = try sut.parse(text: text)


        XCTAssertEqual(structs.first?.accessLevel, .private)
    }

    func test_givenStructWithVariablesAndNestedStruct_whenParse_thenReturnStruct() throws {
        let text = """
        struct A {
            struct B {
                var c: Int
                let d: Int
            }

            var a: Int
            let b: Int
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 2)
        XCTAssertEqual(structs.first?.name, "A")
        XCTAssertEqual(structs.first?.variables.count, 2)
        XCTAssertEqual(structs.first?.variables.first, .makeStub())
    }

    func test_givenStructWithVariablesAndNestedClass_whenParse_thenReturnStruct() throws {
        let text = """
        struct A {
            class B {
                var c: Int
                let d: Int
            }

            var a: Int
            let b: Int
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "A")
        XCTAssertEqual(structs.first?.variables.count, 2)
        XCTAssertEqual(structs.first?.variables.first, .makeStub())
    }

    func test_givenStructWithVariablesAndNestedEnum_whenParse_thenReturnStruct() throws {
        let text = """
        struct A {
            enum B {
                static var c: Int = 0
            }

            var a: Int
            let b: Int
        }
        """

        let structs = try sut.parse(text: text)

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "A")
        XCTAssertEqual(structs.first?.variables.count, 2)
        XCTAssertEqual(structs.first?.variables.first, .makeStub())
    }
}
