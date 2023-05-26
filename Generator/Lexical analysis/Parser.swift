//
//  Parser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class Parser {
    private var buffer: String = ""
    private var results = [Token]()
    private let identifierCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."

    public init() {}

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
            case "[":
                addToResult(.leftSquareBracket)
            case "]":
                addToResult(.rightSquareBracket)
            case "=":
                addToResult(.equal)
            case "?":
                addToResult(.questionMark)
            case ",":
                addToResult(.comma)
            case "<":
                addToResult(.lessThan)
            case ">":
                addToResult(.greaterThan)
            case "-":
                index = parseArrow(from: index, in: text)
            case "_":
                addToResult(.identifier(name: "_"))
            case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "`":
                index = parseName(from: index, in: text)
            case "@":
                index = parseAt(from: index, in: text)
            case "/":
                index = parseCommentAt(from: index, in: text)
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
        var isEndBackwardsQuoteRequired = false

        if text[index] == "`" {
            index = text.index(after: index)
            isEndBackwardsQuoteRequired = true
        }

        let range = index..<text.endIndex
        while range.contains(index) {
            let character = text[index]

            if identifierCharacters.contains(character) {
                buffer += String(character)
            } else {
                if text[index] == "`" && isEndBackwardsQuoteRequired {
                    index = text.index(after: index)
                    addToResult(.identifier(name: buffer))
                } else {
                    determineNameType(name: buffer)
                }

                index = text.index(before: index)
                break
            }

            index = text.index(after: index)
        }

        return index
    }

    private func parseArrow(from index: String.Index, in text: String) -> String.Index {
        let secondIndex = text.index(after: index)

        if text.indices.contains(index) && text.indices.contains(secondIndex) {
            let character = text[index]
            let character2 = text[secondIndex]

            if character == "-" && character2 == ">" {
                addToResult(.arrow)
            }
        }

        return secondIndex
    }

    private func parseAt(from index: String.Index, in text: String) -> String.Index {
        let secondIndex = text.index(after: index)
        guard text.indices.contains(secondIndex) else {
            return index
        }
        let substring = String(text[secondIndex...])

        if parseContains(phrase: "escaping", in: substring) {
            addToResult(.escaping)
            return text.index(secondIndex, offsetBy: 8)
        } else if parseContains(phrase: "autoclosure", in: substring) {
            addToResult(.autoclosure)
            return text.index(secondIndex, offsetBy: 11)
        }
        return index
    }

    private func parseCommentAt(from index: String.Index, in text: String) -> String.Index {
        let secondIndex = text.index(after: index)

        guard text.indices.contains(secondIndex) else {
            return index
        }
        let substring = text[index...]

        if substring.starts(with: "//") {
            return parseLineComment(from: index, in: text, start: "//", end: "\n")
        } else if substring.starts(with: "/*") {
            return parseLineComment(from: index, in: text, start: "/*", end: "*/")
        } else {
            return text.index(after: index)
        }
    }

    private func parseLineComment(from index: String.Index, in text: String, start: String, end: String) -> String.Index {
        let secondIndex = text.index(after: index)
        let substring = text[index...]

        guard substring.starts(with: start) else {
            return secondIndex
        }

        guard let endIndex = substring.startIndex(of: String.SubSequence(end)) else {
            return secondIndex
        }
        return endIndex
    }

    private func parseContains(phrase: String, in text: String) -> Bool {
        let endIndex = text.index(text.startIndex, offsetBy: phrase.count)

        guard text.indices.contains(endIndex) else {
            return false
        }

        let substring = text[..<endIndex]
        return substring == phrase
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
        case "func":
            token = .function
        case "throws":
            token = .throws
        case "async":
            token = .async
        case "some":
            token = .some
        case "any":
            token = .any
        default:
            token = .identifier(name: name)
        }

        addToResult(token)
    }

    private func addToResult(_ token: Token) {
        results.append(token)
    }
}
