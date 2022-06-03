//
//  NilableVariablesParserTests.swift
//  GeneratorTests
//
//  Created by Kryštof Matěj on 03.06.2022.
//  Copyright © 2022 Kryštof Matěj. All rights reserved.
//

@testable import Generator
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxParser
import XCTest

final class NilableVariablesParserTests: XCTestCase {
    private var sut: NilableVariablesParserImpl!

    override func setUp() {
        super.setUp()
        sut = NilableVariablesParserImpl()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func test_givenClassWithoutVariables_whenParse_thenReturnEmptyResult() throws {
        let code = """
        class X2 {
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, [])
    }

    func test_givenClassWithOptionalVariable_whenParse_thenReturnVariable() throws {
        let code = """
        class X2 {
            private var abc: TearDownInteractorImp?
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, ["abc"])
    }

    func test_givenClassWithForceUnwrappedVariable_whenParse_thenReturnVariable() throws {
        let code = """
        class X2 {
            private var abc: TearDownInteractorImp!
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, ["abc"])
    }

    func test_givenClassWithVariable_whenParse_thenReturnEmptyResult() throws {
        let code = """
        class X2 {
            private var abc: TearDownInteractorImp
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, [])
    }

    func test_givenClassWithOptionalVariableInMethod_whenParse_thenReturnEmptyResult() throws {
        let code = """
        class X2 {
            func x() {
                var abc: Int?
            }
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, [])
    }

    func test_givenClassWithVariableInMethod_whenParse_thenReturnEmptyResult() throws {
        let code = """
        class X2 {
            func x() {
                var abc: Int?
            }
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, [])
    }

    func test_givenClassWithOptionalConstant_whenParse_thenReturnEmptyResult() throws {
        let code = """
        class X2 {
            private let abc: TearDownInteractorImp?
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, [])
    }

    func test_givenClassWithForceUnwrappedConstant_whenParse_thenReturnEmptyResult() throws {
        let code = """
        class X2 {
            private let abc: TearDownInteractorImp!
        }
        """
        let classCode = try parseClass(code)

        let variables = sut.parse(from: classCode)

        XCTAssertEqual(variables, [])
    }

    private func parseClass(_ code: String) throws -> ClassDeclSyntax {
        let file = try SyntaxParser.parse(source: code)
        if let result = file.statements.children.first?.as(CodeBlockItemSyntax.self)?.item.as(ClassDeclSyntax.self) {
            return result
        } else {
            throw CodeParseError.missingClass
        }
    }

    private enum CodeParseError: Error {
        case missingClass
    }
}
