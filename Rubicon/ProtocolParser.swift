//
//  ProtocolParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

enum ProtocolParserError: Error {
    case invalidProtocolToken
    case invalidNameToken
    case expectedLeftBracket
    case expectedRightBracket
}

public class ProtocolParser {

    public func parse(storage: Storage) throws -> Protocol {
        guard storage.current == .protocol else {
            throw ProtocolParserError.invalidProtocolToken
        }

        guard let nameToken = try? storage.next(), case let .identifier(name) = nameToken else {
            throw ProtocolParserError.invalidNameToken
        }

        guard let leftBracketToken = try? storage.next(), leftBracketToken == .leftCurlyBracket else {
            throw ProtocolParserError.expectedLeftBracket
        }

        guard let rightBracketToken = try? storage.next(), rightBracketToken == .rightCurlyBracket else {
            throw ProtocolParserError.expectedRightBracket
        }

        _ = try storage.next()
        return Protocol(name: name)
    }
}
