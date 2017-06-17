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
        return try parseStructure()
    }

    public func parseSimpleType() throws -> Type {
        let name = try parseName()
        let isOptional = isOptionalParsed()
        return Type(name: name, isOptional: isOptional)
    }

    private func parseStructure() throws -> Type {
        guard case .leftSquareBracket = storage.current else {
            return try parseSimpleType()
        }

        _ = try storage.next()

        let contentType = try parseSimpleType()
        let resultType: Type

        if isColonParsed() {
            resultType = try parseDictionary(keyType: contentType)
        } else {
            resultType = try parseArray(type: contentType)
        }

        return resultType
    }

    private func parseDictionary(keyType: Type) throws -> Type {
        let valueType = try parseSimpleType()
        try parseRightSquareBracket()
        let isOptional = isOptionalParsed()
        return  Type(name: "[\(keyType.makeString()): \(valueType.makeString())]", isOptional: isOptional)
    }

    private func parseArray(type: Type) throws -> Type {
        try parseRightSquareBracket()
        let isOptional = isOptionalParsed()
        return Type(name: "[\(type.makeString())]", isOptional: isOptional)
    }

    private func parseName() throws -> String {
        guard case let .identifier(name) = storage.current else {
            throw TypeParserError.invalidName
        }

        _ = try? storage.next()
        return name
    }

    private func isOptionalParsed() -> Bool {
        let isOptional = storage.current == .questionMark

        if isOptional {
            _ = try? storage.next()
        }

        return isOptional
    }

    private func isColonParsed() -> Bool {
        let isColon = storage.current == .colon

        if isColon {
            _ = try? storage.next()
        }

        return isColon
    }

    private func parseRightSquareBracket() throws {
        guard case .rightSquareBracket = storage.current else {
            throw TypeParserError.missingEndingBracket
        }

        _ = try storage.next()
    }
}
