//
//  FunctionDeclarationParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class FunctionDeclarationParserTests: XCTestCase {

    func test_givenColon_whenParse_thenThrowException() {
        let parser = FunctionDeclarationParser()
        let storage = try! Storage(tokens: [.colon])
        do {
            _ = try parser.parse(storage: storage)
        } catch let (error as FunctionDeclarationParserError) {
            XCTAssertEqual(error, .invalidFunctionToken)
            return
        } catch {}

        XCTFail()
    }

    func test_givenInvalidNameToken_whenParse_thenThrowInvalidNameException() {
        let parser = FunctionDeclarationParser()
        let storage = try! Storage(tokens: [.function, .colon])
        do {
            _ = try parser.parse(storage: storage)
        } catch let (error as FunctionDeclarationParserError) {
            XCTAssertEqual(error, .invalidNameToken)
            return
        } catch {}

        XCTFail()
    }

    func test_givenInvalidLeftBracketNameToken_whenParse_thenThrowInvalidNameException() {
        let parser = FunctionDeclarationParser()
        let storage = try! Storage(tokens: [.function, .identifier(name: "f"), .colon])
        do {
            _ = try parser.parse(storage: storage)
        } catch let (error as FunctionDeclarationParserError) {
            XCTAssertEqual(error, .invalidLeftBracketToken)
            return
        } catch {}

        XCTFail()
    }

    func test_givenInvalidFunctionArgument_whenParse_thenThrowInvalidFunctionArgumentException() {
        let parser = FunctionDeclarationParser()
        let storage = try! Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .colon])
        do {
            _ = try parser.parse(storage: storage)
        } catch let (error as FunctionDeclarationParserError) {
            XCTAssertEqual(error, .invalidFunctionArgument)
            return
        } catch {}

        XCTFail()
    }

    func test_givenFunction_whenParse_thenParse() {
        let parser = FunctionDeclarationParser()
        let storage = try! Storage(tokens: [.function, .identifier(name: "f"), .leftBracket, .rightBracket, .colon])
        do {
            let definition = try parser.parse(storage: storage)
            XCTAssertEqual(definition.name, "f")
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

}
