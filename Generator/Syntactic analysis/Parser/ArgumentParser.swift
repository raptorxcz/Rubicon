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

    private let typeParser = TypeParser()

    public init() {}

    public func parse(storage: Storage) throws -> ArgumentType {
        guard case .identifier(let label) = storage.current else {
            throw ArgumentParserError.invalidName
        }

        guard let secondToken = try? storage.next() else {
            throw ArgumentParserError.invalidColon
        }

        let argumentType: ArgumentType

        if case .identifier(let name) = secondToken {
            _ = try? storage.next()
            argumentType = try parseColon(in: storage, label: label, name: name)
        } else {
            argumentType = try parseColon(in: storage, label: nil, name: label)
        }

        return argumentType
    }

    private func parseColon(in storage: Storage, label: String?, name: String) throws -> ArgumentType {
        guard storage.current == .colon else {
            throw ArgumentParserError.invalidColon
        }

        _ = try? storage.next()

        guard let type = try? typeParser.parse(storage: storage) else {
            throw ArgumentParserError.invalidType
        }

        return ArgumentType(label: label, name: name, type: type)
    }

}
