//
//  FunctionDeclarationParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum FunctionDeclarationParserError: Error {
    case invalidFunctionToken
    case invalidNameToken
    case invalidLeftBracketToken
    case invalidFunctionArgument
}

public class FunctionDeclarationParser {

    public func parse(storage: Storage) throws -> FunctionDeclarationType {
        let index = storage.currentIndex()
        guard storage.current == .function else {
            throw FunctionDeclarationParserError.invalidFunctionToken
        }

        guard let nextToken = try? storage.next(), case let .identifier(name) = nextToken else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidNameToken
        }

        guard let leftBracketToken = try? storage.next(), leftBracketToken == .leftBracket else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidLeftBracketToken
        }

        guard let rightBracketToken = try? storage.next(), rightBracketToken == .rightBracket else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidFunctionArgument
        }

        _ = try? storage.next()
        return FunctionDeclarationType(name: name)
    }
}
