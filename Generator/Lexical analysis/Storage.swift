//
//  Storage.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum StorageError: Error {
    case noTokens
    case noNextToken
    case noPreviousToken
    case indexOutOfBounds
}

public class Storage {

    public var current: Token {
        return tokens[index]
    }

    private let tokens: [Token]
    private var index = 0

    public init(tokens: [Token]) throws {
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

    public func currentIndex() -> Int {
        return index
    }

    public func setCurrentIndex(_ index: Int) throws {
        guard tokens.indices.contains(index) else {
            throw StorageError.indexOutOfBounds
        }

        self.index = index
    }

    public func moveToNext(_ token: Token) throws {
        let restOfTokens = tokens[index ..< tokens.count]

        if let newIndex = restOfTokens.firstIndex(of: token) {
            index = newIndex
        } else {
            throw StorageError.noNextToken
        }
    }
}
