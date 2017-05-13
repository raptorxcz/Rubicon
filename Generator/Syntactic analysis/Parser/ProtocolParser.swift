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
    case expectedLeftBracket
    case expectedRightBracket
}

public class ProtocolParser {

    private let variableParser = VarDeclarationTypeParser()
    private let functionParser = FunctionDeclarationParser()

    public init() {}

    public func parse(storage: Storage) throws -> ProtocolType {
        guard storage.current == .protocol else {
            throw ProtocolParserError.invalidProtocolToken
        }

        guard let nameToken = try? storage.next(), case let .identifier(name) = nameToken else {
            throw ProtocolParserError.invalidNameToken
        }

        guard let leftBracketToken = try? storage.next(), leftBracketToken == .leftCurlyBracket else {
            throw ProtocolParserError.expectedLeftBracket
        }

        _ = try? storage.next()
        let protocolType = parseProtocol(with: name, storage: storage)

        guard storage.current == .rightCurlyBracket else {
            throw ProtocolParserError.expectedRightBracket
        }

        _ = try? storage.next()
        return protocolType
    }

    private func parseProtocol(with name: String, storage: Storage) -> ProtocolType {
        var variables = [VarDeclarationType]()
        var functions = [FunctionDeclarationType]()

        var isSomethingParsed = true

        while isSomethingParsed {
            isSomethingParsed = false

            if let variable = try? variableParser.parse(storage: storage) {
                variables.append(variable)
                isSomethingParsed = true
            }

            if let function = try? functionParser.parse(storage: storage) {
                functions.append(function)
                isSomethingParsed = true
            }
        }

        return ProtocolType(name: name, variables: variables, functions: functions)
    }
}
