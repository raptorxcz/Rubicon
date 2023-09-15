//
//  TearDownInteractorTests.swift
//  GeneratorTests
//
//  Created by Kryštof Matěj on 19.05.2022.
//  Copyright © 2022 Kryštof Matěj. All rights reserved.
//

@testable import Rubicon
import SwiftSyntax
import XCTest

final class TearDownInteractorTests: XCTestCase {
    private var nilableVariablesParserSpy: NilableVariablesParserSpy!
    private var sut: TearDownInteractor!

    override func setUp() {
        super.setUp()
        nilableVariablesParserSpy = NilableVariablesParserSpy(parseReturn: ["sut", "abc"])
        sut = TearDownInteractor(nilableVariablesParser: nilableVariablesParserSpy)
    }

    override func tearDown() {
        super.tearDown()
        nilableVariablesParserSpy = nil
        sut = nil
    }

    func test_givenSomeClass_whenExecute_thenClassIsNotChanged() throws {
        let text = """
        import Foundation

        class X2 {
            private var sut: TearDownInteractorImp!
            private var abc: TearDownInteractorImp?

            func test_execute() {
                sut.execute(text: "")
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, text)
    }

    func test_givenTestClassWithNilableVariables_whenExecute_thenAddTearDownAtTheEnd() throws {
        let text = """
        import Foundation

        class X3Tests {
            private var sut: TearDownInteractorImp!
            private var abc: TearDownInteractorImp?

            func test_execute() {
                sut.execute(text: "")
            }
        }
        """
        let expectedResult = """
        import Foundation

        class X3Tests {
            private var sut: TearDownInteractorImp!
            private var abc: TearDownInteractorImp?

            func test_execute() {
                sut.execute(text: "")
            }

            override func tearDown() {
                super.tearDown()
                sut = nil
                abc = nil
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(nilableVariablesParserSpy.parse.count, 1)
    }

    func test_givenTestClassWithNilableVariablesAndSetUpMethod_whenExecute_thenAddTearDownAfterSetUpMethod() throws {
        let text = """
        import Foundation

        final class TearDownInteractorTests: XCTestCase {
            private var sut: TearDownInteractorImp!
            private let sut2: TearDownInteractorImp!
            private var sut3: TearDownInteractorImp?
            private var sut4 = TearDownInteractorImp()
            private var sut5 = TearDownInteractorImp?()

            override func setUp() {
                super.setUp()
                sut = TearDownInteractorImp()
                var x: A!
            }

            func test_execute() {
                sut.execute(text: "")
            }

            override func tearDown() {
                print("x")
            }
        }
        """
        let expectedResult = """
        import Foundation

        final class TearDownInteractorTests: XCTestCase {
            private var sut: TearDownInteractorImp!
            private let sut2: TearDownInteractorImp!
            private var sut3: TearDownInteractorImp?
            private var sut4 = TearDownInteractorImp()
            private var sut5 = TearDownInteractorImp?()

            override func setUp() {
                super.setUp()
                sut = TearDownInteractorImp()
                var x: A!
            }

            override func tearDown() {
                super.tearDown()
                sut = nil
                abc = nil
            }

            func test_execute() {
                sut.execute(text: "")
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, expectedResult)
    }

    func test_givenTestClassWithNilableVariablesAndStaticSetUpMethod_whenExecute_thenAddTearDownAtTheEnd() throws {
        let text = """
        import Foundation

        class X4_DO_NOT_ADD_AFTER_SETUP_Tests {
            private var sut: TearDownInteractorImp!
            private var abc: TearDownInteractorImp?

            override static func setUp() {
                super.setUp()
                sut = TearDownInteractorImp()
            }

            func test_execute() {
                sut.execute(text: "")
            }
        }
        """
        let expectedResult = """
        import Foundation

        class X4_DO_NOT_ADD_AFTER_SETUP_Tests {
            private var sut: TearDownInteractorImp!
            private var abc: TearDownInteractorImp?

            override static func setUp() {
                super.setUp()
                sut = TearDownInteractorImp()
            }

            func test_execute() {
                sut.execute(text: "")
            }

            override func tearDown() {
                super.tearDown()
                sut = nil
                abc = nil
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, expectedResult)
    }

    func test_givenTestClassWithNilableVariablesAndSetUpWithErrorMethod_whenExecute_thenAddTearDownAfterSetUpWithErrorMethod() throws {
        let text = """
        import Foundation

        final class TearDownInteractorTests: XCTestCase {
            private var sut: TearDownInteractorImp!
            private let sut2: TearDownInteractorImp!
            private var sut3: TearDownInteractorImp?
            private var sut4 = TearDownInteractorImp()
            private var sut5 = TearDownInteractorImp?()

            override func setUpWithError() {
                super.setUpWithError()
                sut = TearDownInteractorImp()
                var x: A!
            }

            func test_execute() {
                sut.execute(text: "")
            }

            override func tearDown() {
                print("x")
            }
        }
        """
        let expectedResult = """
        import Foundation

        final class TearDownInteractorTests: XCTestCase {
            private var sut: TearDownInteractorImp!
            private let sut2: TearDownInteractorImp!
            private var sut3: TearDownInteractorImp?
            private var sut4 = TearDownInteractorImp()
            private var sut5 = TearDownInteractorImp?()

            override func setUpWithError() {
                super.setUpWithError()
                sut = TearDownInteractorImp()
                var x: A!
            }

            override func tearDown() {
                super.tearDown()
                sut = nil
                abc = nil
            }

            func test_execute() {
                sut.execute(text: "")
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, expectedResult)
    }

    func test_givenSomeClassWithTearDownWithError_whenExecute_thenClassIsNotChanged() throws {
        let text = """
        import Foundation

        class X2 {
            private var sut: TearDownInteractorImp!
            private var abc: TearDownInteractorImp?

            func test_execute() {
                sut.execute(text: "")
            }

            func tearDownWithError() throws {
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, text)
    }

    func test_givenTestClassWithoutNilableVariables_whenExecute_thenRemoveTearDownAtTheEnd() throws {
        nilableVariablesParserSpy.parseReturn = []
        let text = """
        import Foundation

        class X3Tests {
            func test_execute() {
                sut.execute(text: "")
            }

            override func tearDown() {
                super.tearDown()
                sut = nil
                abc = nil
            }
        }
        """
        let expectedResult = """
        import Foundation

        class X3Tests {
            func test_execute() {
                sut.execute(text: "")
            }
        }
        """

        let result = try sut.execute(text: text, spacing: 4)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(nilableVariablesParserSpy.parse.count, 1)
    }
}

final class NilableVariablesParserSpy: NilableVariablesParser {
    struct Parse {
        let node: ClassDeclSyntax
    }

    var parse = [Parse]()
    var parseReturn: [String]

    init(parseReturn: [String]) {
        self.parseReturn = parseReturn
    }

    func parse(from node: ClassDeclSyntax) -> [String] {
        let item = Parse(node: node)
        parse.append(item)
        return parseReturn
    }
}
