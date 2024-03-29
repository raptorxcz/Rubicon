//
//  ArgumentParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 27/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import SwiftParser
import SwiftSyntax

protocol ArgumentDeclarationParser {
    func parse(node: FunctionParameterSyntax) -> ArgumentDeclaration
}

class ArgumentDeclarationParserImpl: ArgumentDeclarationParser {
    private let typeDeclarationParser: TypeDeclarationParser

    init(typeDeclarationParser: TypeDeclarationParser) {
        self.typeDeclarationParser = typeDeclarationParser
    }

    func parse(node: FunctionParameterSyntax) -> ArgumentDeclaration {
        return ArgumentDeclaration(
            label: makeLabel(from: node),
            name: makeName(from: node),
            type: typeDeclarationParser.parse(node: node.type)
        )
    }

    private func makeLabel(from node: FunctionParameterSyntax) -> String? {
        guard node.secondName != nil else {
            return nil
        }

        let token = node.firstName
        return token.text
    }

    private func makeName(from node: FunctionParameterSyntax) -> String {
        guard let secondName = node.secondName else {
            return node.firstName.text
        }

        return secondName.text
    }
}
