//
//  TypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class TypeParser {
    private let storage: Storage

    public init(storage: Storage) {
        self.storage = storage
    }

    public func parse() throws -> TypeDeclaration {
        if isClosure() {
            return try ClosureTypeParser(storage: storage).parse()
        } else {
            return try SimpleTypeParser(storage: storage).parse()
        }
    }

    private func isClosure() -> Bool {
        let currentToken = storage.current
        return (
            currentToken == .escaping ||
            currentToken == .autoclosure ||
            currentToken == .leftBracket
        )
    }
}
