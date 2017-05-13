//
//  StorageTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest
import Generator

class StorageTests: XCTestCase {

    func test_givenNoToken_whenInit_thenThrowException() {
        testStorageException(with: .noTokens) {
            _ = try Storage(tokens: [])
        }
    }

    func test_givenOneToken_whenInit_thenInit() {
        do {
            _ = try Storage(tokens: [.colon])
        } catch {
            XCTFail()
        }
    }

    func test_whenGetCurrentToken_thenReturnFirst() {
        do {
            let storage = try Storage(tokens: [.colon, .comma])
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenOneToken_whenGetNextToken_thenThrowException() {
        testStorageException(with: .noNextToken) {
            let storage = try Storage(tokens: [.colon])
            _ = try storage.next()
        }
    }

    func test_givenTwoTokens_whenGetNextToken_thenReturnSecondToken() {
        do {
            let storage = try Storage(tokens: [.colon, .comma])
            let token = try storage.next()
            XCTAssertEqual(token, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_whenGetPreviousToken_thenThrowException() {
        testStorageException(with: .noPreviousToken) {
            let storage = try Storage(tokens: [.colon])
            _ = try storage.previous()
        }
    }

    func test_givenTwoTokens_whenGetNextAndPreviousToken_thenReturnFirstToken() {
        do {
            let storage = try Storage(tokens: [.colon, .comma])
            let token = try storage.next()
            XCTAssertEqual(token, .comma)
            let firstToken = try storage.previous()
            XCTAssertEqual(firstToken, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_whenGetCurrentIndex_thenReturnIndex() {
        do {
            let storage = try Storage(tokens: [.colon, .comma])
            _ = try storage.next()
            let index = storage.currentIndex()
            XCTAssertEqual(index, 1)
        } catch {
            XCTFail()
        }
    }

    func test_givenInvalidIndex_whenSetIndex_thenThrowException() {
        testStorageException(with: .indexOutOfBounds) {
            let storage = try Storage(tokens: [.colon, .comma])
            try storage.setCurrentIndex(100)
        }
    }

    func test_givenValidIndex_whenSetIndex_thenSetIndex() {
        do {
            let storage = try Storage(tokens: [.colon, .comma])
            try storage.setCurrentIndex(1)
            XCTAssertEqual(storage.current, .comma)
        } catch {
            XCTFail()
        }
    }

    func test_givenTokens_whenNextOccurrenceOfTokenNotExists_thenThrowException() {
        testStorageException(with: .noNextToken) {
            let storage = try Storage(tokens: [.colon, .colon, .colon])
            try storage.moveToNext(.protocol)
        }
    }

    func test_givenTokens_whenMoveToNextOccurrenceOfToken_thenCurrentTokenIsChanged() {
        do {
            let storage = try Storage(tokens: [.colon, .protocol, .comma])
            XCTAssertEqual(storage.current, .colon)
            try storage.moveToNext(.protocol)
            XCTAssertEqual(storage.current, .protocol)
        } catch {
            XCTFail()
        }
    }

    private func testStorageException(with exception: StorageError, parse: (() throws -> Void)) {
        testException(with: exception, parse: parse)
    }
}
