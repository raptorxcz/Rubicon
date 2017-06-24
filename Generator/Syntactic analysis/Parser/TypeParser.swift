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
    case missingIdentifier
    case missingEndingGreaterThan
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
        var name = try parseName()
        let isOptional = isOptionalParsed()

        let subtypes = try parseGenericTypes()

        if !subtypes.isEmpty {
            name += "<\(subtypes.map({ $0.name }).joined(separator: ", "))>"
        }

        return Type(name: name, isOptional: isOptional)
    }

    private func parseGenericTypes() throws -> [Type] {
        guard storage.current == .lessThan else {
            return []
        }

        let types = try parseListedTypes()

        guard storage.current == .greaterThan else {
            throw TypeParserError.missingEndingGreaterThan
        }

        _ = try storage.next()

        return types
    }

    private func parseListedTypes() throws -> [Type] {
        var types = [Type]()

        repeat {
            _ = try storage.next()

            guard let type = try? parseSimpleType() else {
                throw TypeParserError.missingIdentifier
            }
            types.append(type)

        } while (storage.current == .comma)

        return types
    }

    private func parseStructure() throws -> Type {
        guard case .leftSquareBracket = storage.current else {
            return try parseSimpleType()
        }

        _ = try storage.next()

        let contentType = try parse()
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
        return Type(name: "[\(keyType.makeString()): \(valueType.makeString())]", isOptional: isOptional)
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
