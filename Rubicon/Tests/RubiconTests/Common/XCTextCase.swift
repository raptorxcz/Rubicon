//
//  XCTextCase.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Rubicon
import XCTest

extension XCTestCase {

    func testException<E: Error>(with exception: E, parse: (() throws -> Void)) where E: Equatable {
        do {
            try parse()
        } catch let error as E {
            XCTAssertEqual(error, exception)
            return
        } catch {}

        XCTFail()
    }
}
