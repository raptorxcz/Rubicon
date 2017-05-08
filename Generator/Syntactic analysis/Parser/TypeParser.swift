//
//  TypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum TypeParserError: Error {
    case invalidName
}

public class TypeParser {

    public init() {}

    public func parse(storage: Storage) throws -> Type {
        guard case let .identifier(name) = storage.current else {
            throw TypeParserError.invalidName
        }

        if let token = try? storage.next() {
            if token == .questionMark {
                _ = try? storage.next()
                return Type(name: name, isOptional: true)
            }
        }

        return Type(name: name, isOptional: false)
    }
}
