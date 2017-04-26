//
//  VarDeclarationTypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum VarDeclarationTypeError: Error {
    case invalidTokens
}

public class VarDeclarationTypeParser {

    private enum State {
        case start
        case variable
        case name
        case colon
        case type
        case leftCurlyBracket
        case get
        case set
        case setFirst
        case rightCurlyBracket
        case error
    }

    public func parse(storage: Storage) throws -> VarDeclarationType {
        var isConstant = true
        var isEnd = false
        var state = State.start
        var identifier: String?
        var type: Type?

        while !isEnd {
            let token: Token?

            if state != .start, state != .type {
                token = try? storage.next()
            } else {
                token = storage.current
            }

            switch state {
            case .start:
                if token == .variable {
                    state = .variable
                } else {
                    state = .error
                }
            case .variable:
                if let token = token, case .identifier(let name) = token {
                    identifier = name
                    state = .name
                } else {
                    state = .error
                }
            case .name:
                if token == .colon {
                    state = .colon
                } else {
                    state = .error
                }
            case .colon:
                let varType = try? TypeParser().parse(storage: storage)
                if let varType = varType {
                    type = varType
                    state = .type
                } else {
                    state = .error
                }
            case .type:
                if token == .leftCurlyBracket {
                    state = .leftCurlyBracket
                } else {
                    state = .error
                }
            case .leftCurlyBracket:
                if token == .get {
                    state = .get
                } else if token == .set {
                    state = .setFirst
                } else {
                    state = .error
                }
            case .get:
                if token == .set {
                    state = .set
                } else if token == .rightCurlyBracket {
                    state = .rightCurlyBracket
                } else {
                    state = .error
                }
            case .set:
                isConstant = false

                if token == .rightCurlyBracket {
                    state = .rightCurlyBracket
                } else {
                    state = .error
                }
            case .setFirst:
                isConstant = false

                if token == .get {
                    state = .get
                } else {
                    state = .error
                }
            case .rightCurlyBracket:
                if let identifier = identifier, let type = type {
                    return VarDeclarationType(isConstant: isConstant, identifier: identifier, type: type)
                }
            case .error:
                isEnd = true
            }
        }

        throw VarDeclarationTypeError.invalidTokens
    }

}
