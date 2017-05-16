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
    case invalidReturnType
}

public class FunctionDeclarationParser {

    private var argumentParser = ArgumentParser()
    private var typeParser = TypeParser()

    public init() {}

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

        _ = try? storage.next()
        var arguments = [ArgumentType]()

        if let argument = try? argumentParser.parse(storage: storage) {
            arguments.append(argument)
        }

        while storage.current == .comma {
            _ = try? storage.next()

            if let argument = try? argumentParser.parse(storage: storage) {
                arguments.append(argument)
            }
        }

        guard storage.current == .rightBracket else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidFunctionArgument
        }

        _ = try? storage.next()
        var returnType: Type?

        if storage.current == .arrow {
            _ = try? storage.next()

            guard let type = try? typeParser.parse(storage: storage) else {
                throw FunctionDeclarationParserError.invalidReturnType
            }

            returnType = type
        }

        return FunctionDeclarationType(name: name, arguments: arguments, returnType: returnType)
    }
}
