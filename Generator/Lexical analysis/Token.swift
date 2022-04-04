//
//  Token.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum Token: Equatable {
    case identifier(name: String)
    case `protocol`
    case leftCurlyBracket
    case rightCurlyBracket
    case leftBracket
    case rightBracket
    case leftSquareBracket
    case rightSquareBracket
    case lessThan
    case greaterThan
    case colon
    case comma
    case questionMark
    case equal
    case variable
    case constant
    case function
    case arrow
    case `throws`
    case escaping
    case autoclosure
    case `async`
}
