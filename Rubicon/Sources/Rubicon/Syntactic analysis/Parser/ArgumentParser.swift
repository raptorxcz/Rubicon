//
//  ArgumentParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 27/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum ArgumentParserError: Error {
    case invalidName
    case invalidColon
    case invalidType
}

public class ArgumentParser {

    public init() {}

    public func parse(storage: Storage) throws -> ArgumentDeclaration {
        guard case let .identifier(label) = storage.current else {
            throw ArgumentParserError.invalidName
        }

        guard let secondToken = try? storage.next() else {
            throw ArgumentParserError.invalidColon
        }

        let argumentType: ArgumentDeclaration

        if case let .identifier(name) = secondToken {
            _ = try? storage.next()
            argumentType = try parseColon(in: storage, label: label, name: name)
        } else {
            argumentType = try parseColon(in: storage, label: nil, name: label)
        }

        return argumentType
    }

    private func parseColon(in storage: Storage, label: String?, name: String) throws -> ArgumentDeclaration {
        guard storage.current == .colon else {
            throw ArgumentParserError.invalidColon
        }

        _ = try? storage.next()

        let typeParser = TypeParser(storage: storage)
        guard let type = try? typeParser.parse() else {
            throw ArgumentParserError.invalidType
        }

        return ArgumentDeclaration(label: label, name: name, type: type)
    }
}
