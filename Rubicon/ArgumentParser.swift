//
//  ArgumentParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 27/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

enum ArgumentParserError: Error {
    case invalidName
    case invalidColon
    case invalidType
}

public class ArgumentParser {

    private let typeParser = TypeParser()

    func parse(storage: Storage) throws -> ArgumentType {
        guard case .identifier(let label) = storage.current else {
            throw ArgumentParserError.invalidName
        }

        guard let secondToken = try? storage.next() else {
            throw ArgumentParserError.invalidColon
        }

        if case .identifier(let name) = secondToken {
            _ = try? storage.next()
            return try parseColon(in: storage, label: label, name: name)
        } else {
            return try parseColon(in: storage, label: nil, name: label)
        }
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
