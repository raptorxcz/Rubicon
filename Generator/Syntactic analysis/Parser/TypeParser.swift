//
//  TypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum TypeParserError: Error {
    case invalidName
    case missingEndingBracket
}

public class TypeParser {

    private let storage: Storage

    public init(storage: Storage) {
        self.storage = storage
    }

    public func parse() throws -> Type {
        return try parseArray()
    }

    public func parseSimpleType() throws -> Type {
        let name = try parseName()
        let isOptional = parseIfIsOptional()
        return Type(name: name, isOptional: isOptional)
    }

    private func parseArray() throws -> Type {
        guard case .leftSquareBracket = storage.current else {
            return try parseSimpleType()
        }

        _ = try storage.next()
        let type = try parseSimpleType()

        try parseRightSquareBracket()
        _ = try storage.next()
        let isOptional = parseIfIsOptional()
        return Type(name: "[\(type.makeString())]", isOptional: isOptional)
    }

    private func parseName() throws -> String {
        guard case let .identifier(name) = storage.current else {
            throw TypeParserError.invalidName
        }

        _ = try? storage.next()
        return name
    }

    private func parseIfIsOptional() -> Bool {
        if storage.current == .questionMark {
            _ = try? storage.next()
            return true
        } else {
            return false
        }
    }

    private func parseRightSquareBracket() throws {
        guard case .rightSquareBracket = storage.current else {
            throw TypeParserError.missingEndingBracket
        }
    }
}
