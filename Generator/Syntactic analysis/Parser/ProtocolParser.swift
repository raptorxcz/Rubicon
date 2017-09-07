//
//  ProtocolParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum ProtocolParserError: Error {
    case invalidProtocolToken
    case invalidNameToken
    case expectedParentProtocol
    case expectedLeftBracket
    case expectedRightBracket
}

public class ProtocolParser {

    private let variableParser = VarDeclarationTypeParser()

    public init() {}

    public func parse(storage: Storage) throws -> ProtocolType {
        guard storage.current == .protocol else {
            throw ProtocolParserError.invalidProtocolToken
        }

        guard let nameToken = try? storage.next(), case let .identifier(name) = nameToken else {
            throw ProtocolParserError.invalidNameToken
        }

        let parents: [String]

        if let nextToken = try? storage.next(), nextToken == .colon {
            parents = try parseParents(storage: storage)
        } else {
            parents = []
        }

        guard storage.current == .leftCurlyBracket else {
            throw ProtocolParserError.expectedLeftBracket
        }

        _ = try? storage.next()
        let protocolType = parseProtocol(with: name, parents: parents, storage: storage)

        guard storage.current == .rightCurlyBracket else {
            throw ProtocolParserError.expectedRightBracket
        }

        _ = try? storage.next()
        return protocolType
    }

    private func parseParents(storage: Storage) throws -> [String] {
        var parents = [String]()
        var continueRepeating = false

        repeat {
            continueRepeating = false

            guard let parentToken = try? storage.next(), case let .identifier(parentName) = parentToken else {
                throw ProtocolParserError.expectedParentProtocol
            }

            parents.append(parentName)

            guard let separatorToken = try? storage.next() else {
                throw ProtocolParserError.expectedLeftBracket
            }

            if separatorToken == .comma {
                continueRepeating = true
            }
        } while continueRepeating

        return parents
    }
    private func parseProtocol(with name: String, parents: [String], storage: Storage) -> ProtocolType {
        var variables = [VarDeclarationType]()
        var functions = [FunctionDeclarationType]()

        var isSomethingParsed = true

        while isSomethingParsed {
            isSomethingParsed = false

            if let variable = try? variableParser.parse(storage: storage) {
                variables.append(variable)
                isSomethingParsed = true
            }

            if let function = try? FunctionDeclarationParser(storage: storage).parse() {
                functions.append(function)
                isSomethingParsed = true
            }
        }

        return ProtocolType(name: name, parents: parents, variables: variables, functions: functions)
    }
}
