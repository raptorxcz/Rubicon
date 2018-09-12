//
//  ClosureTypeParser.swift
//  Generator
//
//  Created by Jan Halousek on 10.09.18.
//  Copyright © 2018 Kryštof Matěj. All rights reserved.
//

public enum ClosureTypeParserError: Error {
    case invalidStartToken
    case missingClosureArrow
    case missingClosureReturnType
    case missingEndingBracket
}

public class ClosureTypeParser {
    private let storage: Storage

    public init(storage: Storage) {
        self.storage = storage
    }

    public func parse() throws -> Type {
        guard isFirstTokenValidForClosure() else {
            throw ClosureTypeParserError.invalidStartToken
        }
        return try parseClosure()
    }

    private func parseClosure() throws -> Type {
        let prefix = try parsePrefix()

        guard try parseIsLeftBracket() else {
            return try parseSimpleTypeClosure(prefix: prefix)
        }

        let hasBoundingBrackets = try parseIsLeftBracket()

        let parametersTypes = try parseParametersList()
        let isThrowing = try parseIsThrowing()
        try parseArrow()
        let returnType = try parseSimpleType()

        if hasBoundingBrackets {
            try parseRightBracket()
        }
        var isOptional = false
        if hasBoundingBrackets {
            isOptional = try parseIsOptional()
        }

        let name = makeClosureName(parameters: parametersTypes, returnType: returnType, isOptional: isOptional, isThrowing: isThrowing)
        return Type(name: name, isOptional: isOptional, isClosure: true, prefix: prefix)
    }

    private func parseSimpleTypeClosure(prefix: TypePrefix?) throws -> Type {
        var simpleType = try parseSimpleType()
        simpleType.isClosure = true
        simpleType.prefix = prefix
        return simpleType
    }

    private func parseParametersList() throws -> [Type] {
        var types = [Type]()

        while !isCurrentTokenRightBracket() {
            types.append(try parseSimpleType())

            if !(try parseIsComma()) {
                break
            }
        }
        _ = try storage.next()
        
        return types
    }

    private func parseSimpleType() throws -> Type {
        return try SimpleTypeParser(storage: storage).parse()
    }

    private func isFirstTokenValidForClosure() -> Bool {
        let currentToken = storage.current
        return (
            currentToken == .escaping ||
            currentToken == .autoclosure ||
            currentToken == .leftBracket
        )
    }

    private func isCurrentTokenRightBracket() -> Bool {
        return storage.current == .rightBracket
    }

    private func parsePrefix() throws -> TypePrefix? {
        if try parseIs(token: .escaping) {
            return .escaping
        } else if try parseIs(token: .autoclosure) {
            return .autoclosure
        }
        return nil
    }

    private func parseRightBracket() throws {
        _ = try parseIs(token: .rightBracket)
    }

    private func parseIsLeftBracket() throws -> Bool {
        return try parseIs(token: .leftBracket)
    }

    private func parseIsThrowing() throws -> Bool {
        return try parseIs(token: .throws)
    }

    private func parseIsOptional() throws -> Bool {
        return try parseIs(token: .questionMark)
    }

    private func parseArrow() throws {
        guard case .arrow = storage.current else {
            throw ClosureTypeParserError.missingClosureArrow
        }
        _ = try storage.next()
    }

    private func parseIsComma() throws -> Bool {
        return try parseIs(token: .comma)
    }

    private func parseIs(token: Token) throws -> Bool {
        guard storage.current == token else {
            return false
        }
        _ = try storage.next()
        return true
    }

    private func makeClosureName(parameters: [Type], returnType: Type, isOptional: Bool, isThrowing: Bool) -> String {
        let parametersString = parameters
            .map { TypeStringFactory.makeSimpleString($0) }
            .joined(separator: ", ")
        let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
        var name = (isOptional ? "(" : "")
        name += "(" + parametersString + ")"
        name += (isThrowing ? " throws" : "")
        name += " -> "
        name += returnTypeString
        if isOptional {
            name += ")"
        }
        return name
    }
}
