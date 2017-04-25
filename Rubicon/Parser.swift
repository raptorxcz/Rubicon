//
//  Parser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class Parser {

    private let identifierCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"

    private var buffer: String = ""
    private var results = [Token]()

    public init() {
    }

    public func parse(_ text: String) -> [Token] {
        let text = text + " "
        var index = text.startIndex
        let range = text.startIndex..<text.endIndex

        while range.contains(index) {
            switch text[index] {
            case ":":
                addToResult(.colon)
            case "{":
                addToResult(.leftCurlyBracket)
            case "}":
                addToResult(.rightCurlyBracket)
            case "(":
                addToResult(.leftBracket)
            case ")":
                addToResult(.rightBracket)
            case "=":
                addToResult(.equal)
            case "?":
                addToResult(.questionMark)
            case ",":
                addToResult(.comma)
            case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z":
                index = parseName(from: index, in: text)
            default:
                break
            }

            index = text.index(after: index)
        }

        return results
    }

    private func parseName(from index: String.Index, in text: String) -> String.Index {
        var index = index
        buffer = ""

        while text.characters.indices.contains(index) {
            let character = text[index]

            if identifierCharacters.characters.contains(character) {
                buffer += String(character)
            } else {
                determineNameType(name: buffer)
                return text.index(before: index)
            }

            index = text.index(after: index)
        }

        return index
    }

    private func determineNameType(name: String) {
        let token: Token

        switch name {
        case "protocol":
            token = .protocol
        case "var":
            token = .variable
        case "let":
            token = .constant
        case "get":
            token = .get
        case "set":
            token = .set
        case "func":
            token = .function
        default:
            token = .identifier(name: name)
        }

        addToResult(token)
    }

    private func addToResult(_ token: Token) {
        results.append(token)
    }

}
