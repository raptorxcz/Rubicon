//
//  TypeParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest

class TypeParserTests: XCTestCase {

    func test_givenNoToken_whenParse_thenThrowException() {
        let parser = TypeParser()

        do {
            try parser.parse(tokens: [])
        } catch {
            return
        }

        XCTFail()
    }

}
