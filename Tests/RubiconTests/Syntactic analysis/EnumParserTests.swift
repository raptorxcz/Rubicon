@testable import Rubicon
import SwiftParser
import SwiftSyntax
import XCTest

final class EnumParserTests: XCTestCase {
    private var sut: EnumParserImpl!

    override func setUp() {
        super.setUp()
        sut = EnumParserImpl()
    }

    func test_givenNoEnum_whenParse_thenReturnEmptyResult() throws {
        let text = """
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 0)
    }

    func test_givenEmptyEnum_whenParse_thenReturnEnum() throws {
        let text = """
        enum A {
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "A")
        XCTAssertEqual(enums.first?.cases.count, 0)
        XCTAssertEqual(enums.first?.notes, [])
        XCTAssertEqual(enums.first?.accessLevel, .internal)
    }

    func test_givenEnumWithVariables_whenParse_thenReturnEnum() throws {
        let text = """
        enum A {
            case a
            case b
            case c,d
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "A")
        XCTAssertEqual(enums.first?.cases.count, 4)
        XCTAssertEqual(enums.first?.cases.first, "a")
    }

    func test_givenEnumNestedInClass_whenParse_thenReturnEnum() throws {
        let text = """
        class B {
            enum A {
            }
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "B.A")
        XCTAssertEqual(enums.first?.cases.count, 0)
    }

    func test_givenEnumNestedInStruct_whenParse_thenReturnEnum() throws {
        let text = """
        struct B {
            enum A {
            }
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "B.A")
        XCTAssertEqual(enums.first?.cases.count, 0)
    }

    func test_givenEnumNestedInEnum_whenParse_thenReturnEnum() throws {
        let text = """
        enum B {
            enum A {
            }
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 2)
        XCTAssertEqual(enums.first?.name, "B")
        XCTAssertEqual(enums.first?.cases.count, 0)
        XCTAssertEqual(enums.last?.name, "B.A")
        XCTAssertEqual(enums.last?.cases.count, 0)
    }

    func test_givenEnumNestedIntoMultipleItems_whenParse_thenReturnEnum() throws {
        let text = """
        class B {
            struct C {
                enum D {
                    enum A {
                    }
                }
            }
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 2)
        XCTAssertEqual(enums.first?.name, "B.C.D")
        XCTAssertEqual(enums.first?.cases.count, 0)
        XCTAssertEqual(enums.last?.name, "B.C.D.A")
    }

    func test_givenEmptyWithNote_whenParse_thenReturnEnum() throws {
        let text = """
        // NOTE
        enum A {
        }
        """

        let enums = try sut.parse(text: text)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "A")
        XCTAssertEqual(enums.first?.cases.count, 0)
        XCTAssertEqual(enums.first?.notes, ["// NOTE"])
    }

    func test_givenPublicEnum_whenParse_thenReturnEnum() throws {
        let text = """
        public enum A {
        }
        """

        let enums = try sut.parse(text: text)


        XCTAssertEqual(enums.first?.accessLevel, .public)
    }

    func test_givenPrivateEnum_whenParse_thenReturnEnum() throws {
        let text = """
        private enum A {
        }
        """

        let enums = try sut.parse(text: text)


        XCTAssertEqual(enums.first?.accessLevel, .private)
    }
}
