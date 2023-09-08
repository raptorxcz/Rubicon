//
//  SimpleTypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum SimpleTypeParserError: Error {
    case invalidName
    case missingEndingBracket
    case missingIdentifier
    case missingEndingGreaterThan
}

public class SimpleTypeParser {

    private let storage: Storage

    public init(storage: Storage) {
        self.storage = storage
    }

    public func parse() throws -> TypeDeclaration {
        return try parseStructure()
    }

    public func parseSimpleType() throws -> TypeDeclaration {
        let existencial = parseExistencial()
        var name = try parseName()
        let isOptional = isOptionalParsed()

        let subtypes = try parseGenericTypes()

        if !subtypes.isEmpty {
            name += "<\(subtypes.map({ $0.name }).joined(separator: ", "))>"
        }

        return TypeDeclaration(name: name, isOptional: isOptional, existencial: existencial)
    }

    private func parseExistencial() -> String? {
        if storage.current == .some {
            _ = try? storage.next()
            return "some"
        } else if storage.current == .any {
            _ = try? storage.next()
            return "any"
        } else {
            return nil
        }
    }

    private func parseGenericTypes() throws -> [TypeDeclaration] {
        guard storage.current == .lessThan else {
            return []
        }

        let types = try parseListedTypes()

        guard storage.current == .greaterThan else {
            throw SimpleTypeParserError.missingEndingGreaterThan
        }

        _ = try storage.next()

        return types
    }

    private func parseListedTypes() throws -> [TypeDeclaration] {
        var types = [TypeDeclaration]()

        repeat {
            _ = try storage.next()

            guard let type = try? parseSimpleType() else {
                throw SimpleTypeParserError.missingIdentifier
            }
            types.append(type)

        } while (storage.current == .comma)

        return types
    }

    private func parseStructure() throws -> TypeDeclaration {
        guard case .leftSquareBracket = storage.current else {
            return try parseSimpleType()
        }

        _ = try storage.next()

        let contentType = try parse()
        let resultType: TypeDeclaration

        if isColonParsed() {
            resultType = try parseDictionary(keyType: contentType)
        } else {
            resultType = try parseArray(type: contentType)
        }

        return resultType
    }

    private func parseDictionary(keyType: TypeDeclaration) throws -> TypeDeclaration {
        let existencial = parseExistencial()
        let valueType = try parseSimpleType()
        try parseRightSquareBracket()
        let isOptional = isOptionalParsed()
        return TypeDeclaration(name: "[\(makeTypeString(keyType)): \(makeTypeString(valueType))]", isOptional: isOptional, existencial: existencial)
    }

    private func parseArray(type: TypeDeclaration) throws -> TypeDeclaration {
        let existencial = parseExistencial()
        try parseRightSquareBracket()
        let isOptional = isOptionalParsed()
        return TypeDeclaration(name: "[\(makeTypeString(type))]", isOptional: isOptional, existencial: existencial)
    }

    private func parseName() throws -> String {
        guard case let .identifier(name) = storage.current else {
            throw SimpleTypeParserError.invalidName
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
            throw SimpleTypeParserError.missingEndingBracket
        }

        _ = try storage.next()
    }

    private func makeTypeString(_ type: TypeDeclaration) -> String {
        return TypeStringFactory.makeSimpleString(type)
    }
}
