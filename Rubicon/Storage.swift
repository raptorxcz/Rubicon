//
//  Storage.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

enum StorageError: Error {
    case noTokens
    case noNextToken
    case noPreviousToken
}

public class Storage {

    public var current: Token {
        return tokens[index]
    }
    private let tokens: [Token]
    private var index = 0

    init(tokens: [Token]) throws {
        guard !tokens.isEmpty else {
            throw StorageError.noTokens
        }

        self.tokens = tokens
    }

    public func next() throws -> Token {
        let newIndex = index + 1

        guard tokens.indices.contains(newIndex) else {
            throw StorageError.noNextToken
        }

        index = newIndex
        return current
    }

    public func previous() throws -> Token {
        let newIndex = index - 1

        guard tokens.indices.contains(newIndex) else {
            throw StorageError.noPreviousToken
        }

        index = newIndex
        return current
    }

}
