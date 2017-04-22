//
//  VarDeclarationType.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

enum VarDeclarationTypeError: Error {
    case invalidTokens
}

public struct VarDeclarationType {

    private enum State {
        case start
        case variable
        case name
        case colon
        case type
        case questionMark
        case leftCurlyBracket
        case get
        case set
        case setFirst
        case rightCurlyBracket
        case error
    }

    public var isConstant: Bool
    public var identifier: String
    public var type: String
    public var isOptional: Bool

    public init(tokens: [Token]) throws {
        var isConstant = true
        var isEnd = false
        var state = State.start
        var tokens = tokens
        var identifier: String?
        var type: String?
        var isOptional = false

        while !isEnd {
            let token = tokens.first

            if token != nil {
                tokens.removeFirst()
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
                if let token = token, case .identifier(let varType) = token {
                    type = varType
                    state = .type
                } else {
                    state = .error
                }
            case .type:
                if token == .leftCurlyBracket {
                    state = .leftCurlyBracket
                } else if token == .questionMark {
                    state = .questionMark
                } else {
                    state = .error
                }
            case .questionMark:
                isOptional = true
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
                    self.type = type
                    self.identifier = identifier
                    self.isConstant = isConstant
                    self.isOptional = isOptional
                    return
                }
            case .error:
                isEnd = true
            }
        }

        throw VarDeclarationTypeError.invalidTokens
    }

}
