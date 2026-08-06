//
//  FunctionDeclarationParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import SwiftParser
import SwiftSyntax

protocol FunctionDeclarationParser {
    func parse(node: FunctionDeclSyntax) -> FunctionDeclaration
}

final class FunctionDeclarationParserImpl: FunctionDeclarationParser {
    private let typeDeclarationParser: TypeDeclarationParser
    private let argumentDeclarationParser: ArgumentDeclarationParser

    init(
        typeDeclarationParser: TypeDeclarationParser,
        argumentDeclarationParser: ArgumentDeclarationParser
    ) {
        self.typeDeclarationParser = typeDeclarationParser
        self.argumentDeclarationParser = argumentDeclarationParser
    }

    func parse(node: FunctionDeclSyntax) -> FunctionDeclaration {
        return FunctionDeclaration(
            name: node.name.text,
            arguments: node.signature.parameterClause.parameters.map(argumentDeclarationParser.parse(node:)),
            throwing: parseThrowing(node: node),
            isAsync: node.signature.effectSpecifiers?.asyncSpecifier != nil,
            returnType: (node.signature.returnClause?.type).map(typeDeclarationParser.parse(node:))
        )
    }

    private func parseThrowing(node: FunctionDeclSyntax) -> ThrowsDeclaration {
        guard let clause = node.signature.effectSpecifiers?.throwsClause else {
            return .none
        }

        if let typeNode = clause.type {
            return .specific(typeDeclarationParser.parse(node: typeNode))
        } else {
            return .generic
        }
    }
}
