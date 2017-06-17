//
//  Token.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum Token {
    case identifier(name: String)
    case `protocol`
    case leftCurlyBracket
    case rightCurlyBracket
    case leftBracket
    case rightBracket
    case leftSquareBracket
    case rightSquareBracket
    case colon
    case comma
    case questionMark
    case equal
    case variable
    case constant
    case get
    case set
    case function
    case arrow
}

extension Token: Equatable {
    public static func ==(lhs: Token, rhs: Token) -> Bool {

        switch (lhs, rhs) {
        case let (.identifier(name1), .identifier(name2)) :
            return name1 == name2
        case (.protocol, .protocol):
            return true
        case (.leftCurlyBracket, .leftCurlyBracket):
            return true
        case (.rightCurlyBracket, .rightCurlyBracket):
            return true
        case (.leftBracket, .leftBracket):
            return true
        case (.rightBracket, .rightBracket):
            return true
        case (.colon, .colon):
            return true
        case (.comma, .comma):
            return true
        case (.questionMark, .questionMark):
            return true
        case (.equal, .equal):
            return true
        case (.variable, .variable):
            return true
        case (.constant, .constant):
            return true
        case (.get, .get):
            return true
        case (.set, .set):
            return true
        case (.function, .function):
            return true
        case (.arrow, .arrow):
            return true
        case (.leftSquareBracket, .leftSquareBracket):
            return true
        case (.rightSquareBracket, .rightSquareBracket):
            return true
        default:
            return false
        }
    }
}
