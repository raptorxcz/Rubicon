//
//  VarDeclarationTypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import SwiftParser
import SwiftSyntax

protocol VarDeclarationParser {
    func parse(node: some SyntaxProtocol) throws -> VarDeclaration
}

enum VarDeclarationError: Error {
    case missingDeclaration
}

final class VarDeclarationParserImpl: VarDeclarationParser {
    private let typeDeclarationParser: TypeDeclarationParser

    public init(typeDeclarationParser: TypeDeclarationParser) {
        self.typeDeclarationParser = typeDeclarationParser
    }

    func parse(node: some SyntaxProtocol) throws -> VarDeclaration {
        let visitor = VariableVisitor(typeDeclarationParser: typeDeclarationParser)
        return try visitor.execute(node: node)
    }
}

private class VariableVisitor: SyntaxVisitor {
    private let typeDeclarationParser: TypeDeclarationParser
    private var result: VarDeclaration?

    public init(typeDeclarationParser: TypeDeclarationParser) {
        self.typeDeclarationParser = typeDeclarationParser
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) throws -> VarDeclaration {
        walk(node)

        if let result {
            return result
        } else {
            throw VarDeclarationError.missingDeclaration
        }
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let binding = node.bindings.first else {
            return .visitChildren
        }

        guard
            let typeAnnotation = binding.typeAnnotation,
            let type = try? typeDeclarationParser.parse(node: typeAnnotation.type)
        else {
            return .visitChildren
        }


        result = VarDeclaration(
            prefix: nil,
            isConstant: isConstant(token: node.bindingSpecifier),
            identifier: binding.pattern.description,
            type: type
        )
        return .skipChildren
    }

    private func isConstant(token: TokenSyntax) -> Bool {
        switch token.tokenKind {
        case .keyword(.let):
            return true
        default:
            return false
        }
    }
}
