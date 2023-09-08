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

    private let argumentParser = ArgumentParser()
    private let storage: Storage

    public init(storage: Storage) {
        self.storage = storage
    }

    public func parse() throws -> FunctionDeclaration {
        let index = storage.currentIndex()
        try parseFuncKeyword()

        guard let nextToken = try? storage.next(), case let .identifier(name) = nextToken else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidNameToken
        }

        guard let leftBracketToken = try? storage.next(), leftBracketToken == .leftBracket else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidLeftBracketToken
        }

        moveToNextIfPossible()
        let arguments = parseArguments()

        guard storage.current == .rightBracket else {
            try? storage.setCurrentIndex(index)
            throw FunctionDeclarationParserError.invalidFunctionArgument
        }

        moveToNextIfPossible()

        let isAsyncFunction = isAsync()

        if isAsyncFunction {
            moveToNextIfPossible()
        }

        let isThrowingFunction = isThrowing()

        if isThrowingFunction {
            moveToNextIfPossible()
        }

        var returnType: TypeDeclaration?

        if storage.current == .arrow {
            moveToNextIfPossible()

//            let typeParser = TypeDeclarationParser(storage: storage)
//            guard let type = try? typeParser.parse() else {
//                throw FunctionDeclarationParserError.invalidReturnType
//            }

//            returnType = type
        }

        return FunctionDeclaration(name: name, arguments: arguments, isThrowing: isThrowingFunction, isAsync: isAsyncFunction, returnType: returnType)
    }

    private func isAsync() -> Bool {
        return storage.current == .async
    }

    private func isThrowing() -> Bool {
        return storage.current == .throws
    }

    private func moveToNextIfPossible() {
        _ = try? storage.next()
    }

    private func parseFuncKeyword() throws {
        guard storage.current == .function else {
            throw FunctionDeclarationParserError.invalidFunctionToken
        }
    }

    private func parseArguments() -> [ArgumentDeclaration] {
        var arguments = [ArgumentDeclaration]()

        if let argument = try? argumentParser.parse(storage: storage) {
            arguments.append(argument)
        }

        while storage.current == .comma {
            moveToNextIfPossible()

            if let argument = try? argumentParser.parse(storage: storage) {
                arguments.append(argument)
            }
        }

        return arguments
    }
}
