//
//  TypeDeclarationParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import SwiftParser
import SwiftSyntax

protocol TypeDeclarationParser {
    func parse(node: some SyntaxProtocol) throws -> TypeDeclaration
}

enum TypeDeclarationParserError: Error {
    case missingDeclaration
}

final class TypeDeclarationParserImpl: TypeDeclarationParser {
    func parse(node: some SyntaxProtocol) throws -> TypeDeclaration {
        let visitor = TypeVisitor()
        return try visitor.execute(node: node)
    }
}

private final class TypeVisitor: SyntaxVisitor {
    private var result: TypeDeclaration?

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) throws -> TypeDeclaration {
        walk(node)

        if let result {
            return result
        } else {
            throw TypeDeclarationParserError.missingDeclaration
        }
    }

    override func visit(_ node: ForceUnwrapExprSyntax) -> SyntaxVisitorContinueKind {
        result = TypeDeclaration(
            name: node.description,
            isOptional: false,
            existencial: nil
        )

        return .skipChildren
    }

    override func visit(_ node: OptionalChainingExprSyntax) -> SyntaxVisitorContinueKind {
        result = TypeDeclaration(
            name: node.description,
            isOptional: true,
            existencial: nil
        )

        return .skipChildren
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        result = TypeDeclaration(
            name: node.baseName.text,
            isOptional: false,
            existencial: nil
        )

        return .skipChildren
    }

    override func visit(_ node: SequenceExprSyntax) -> SyntaxVisitorContinueKind {
        let isOptional = node.elements.last?.as(OptionalChainingExprSyntax.self) != nil

        result = TypeDeclaration(
            name: node.description,
            isOptional: isOptional,
            isClosure: false,
            existencial: nil
        )

        return .skipChildren
    }

    override func visit(_ node: GenericSpecializationExprSyntax) -> SyntaxVisitorContinueKind {
        result = TypeDeclaration(
            name: node.description,
            isOptional: false,
            isClosure: false,
            existencial: nil
        )

        return .skipChildren
    }

    override func visit(_ node: DictionaryExprSyntax) -> SyntaxVisitorContinueKind {
        result = TypeDeclaration(
            name: node.description,
            isOptional: false,
            isClosure: false,
            existencial: nil
        )

        return .skipChildren
    }

    override func visit(_ node: TypeExprSyntax) -> SyntaxVisitorContinueKind {
        result = TypeDeclaration(
            name: node.description,
            isOptional: false,
            isClosure: false,
            existencial: nil
        )

        return .skipChildren
    }
}
