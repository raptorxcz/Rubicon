//
//  TearDownInteractor.swift
//  Generator
//
//  Created by Kryštof Matěj on 19.05.2022.
//  Copyright © 2022 Kryštof Matěj. All rights reserved.
//

import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder

public final class TearDownInteractor {
    private let nilableVariablesParser: NilableVariablesParser

    public init(nilableVariablesParser: NilableVariablesParser) {
        self.nilableVariablesParser = nilableVariablesParser
    }

    public func execute(text: String, spacing: Int) throws -> String {
        let file = SwiftParser.Parser.parse(source: text)
        let classRewriter = ClassRewriter(
            nilableVariablesParser: nilableVariablesParser,
            spacing: spacing
        )
        return classRewriter.rewrite(file.root).description
    }
}

private class ClassRewriter: SyntaxRewriter {
    private let nilableVariablesParser: NilableVariablesParser
    private let spacing: Int

    init(nilableVariablesParser: NilableVariablesParser, spacing: Int) {
        self.nilableVariablesParser = nilableVariablesParser
        self.spacing = spacing
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        guard isRelevantClass(node: node) else {
            return super.visit(node)
        }

        var node = node

        node.memberBlock.members = node.memberBlock.members.filter { item in
            !isTearDownMethod(item)
        }

        let nilableVariables = nilableVariablesParser.parse(from: node)
        let tearDownMethod = makeTearDownMethod(variables: nilableVariables)

        if let index = firstIndex(node: node, staticMethodName: "setUp"), !nilableVariables.isEmpty {
            let newIndex = node.memberBlock.members.index(index, offsetBy: 1)
            node.memberBlock.members.insert(tearDownMethod, at: newIndex)
        } else if let index = firstIndex(node: node, staticMethodName: "setUpWithError"), !nilableVariables.isEmpty {
            let newIndex = node.memberBlock.members.index(index, offsetBy: 1)
            node.memberBlock.members.insert(tearDownMethod, at: newIndex)
        } else if !nilableVariables.isEmpty {
            node.memberBlock.members.append(tearDownMethod)
        }

        return super.visit(node)
    }

    private func isRelevantClass(node: ClassDeclSyntax) -> Bool {
        guard node.name.text.hasSuffix("Tests") else {
            return false
        }

        guard firstIndex(node: node, staticMethodName: "tearDownWithError") == nil else {
            return false
        }

        return true
    }

    private func makeTearDownMethod(variables: [String]) -> MemberBlockItemSyntax {
        let modifiers = DeclModifierListSyntax([
            DeclModifierSyntax(
                leadingTrivia: .space,
                name: .keyword(.override),
                trailingTrivia: .space
            ),
        ])
        let leftBrace = TokenSyntax.leftBraceToken(leadingTrivia: .spaces(1))
        let rightBrace = TokenSyntax.rightBraceToken(leadingTrivia: Trivia(pieces: [.newlines(1), .spaces(spacing)]))
        let parameterClause = FunctionParameterClauseSyntax(
            leftParen: .leftParenToken(),
            parameters: FunctionParameterListSyntax([]),
            rightParen: .rightParenToken()
        )
        let signature = FunctionSignatureSyntax(parameterClause: parameterClause)
        var function = FunctionDeclSyntax(
            attributes: AttributeListSyntax(),
            modifiers: modifiers,
            funcKeyword: .keyword(.func),
            name: .identifier("tearDown", leadingTrivia: .space),
            genericParameterClause: nil,
            signature: signature,
            genericWhereClause: nil,
            body: CodeBlockSyntax(
                leftBrace: leftBrace,
                statements: CodeBlockItemListSyntax([makeSuperRow()] + variables.map(makeRow)),
                rightBrace: rightBrace
            )
        )
        function.leadingTrivia = Trivia(pieces: [.newlines(2), .spaces(spacing)])
        return MemberBlockItemSyntax(
            decl: DeclSyntax(function),
            semicolon: nil
        )
    }

    private func makeSuperRow() -> CodeBlockItemSyntax {
        let superExpression = SuperExprSyntax(superKeyword: .keyword(.super))
        let memberExpression = MemberAccessExprSyntax(
            leadingTrivia: Trivia(pieces: [.newlines(1), .spaces(2 * spacing)]),
            base: superExpression,
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(baseName: "tearDown")
        )
        let syntax = FunctionCallExprSyntax(
            calledExpression: memberExpression,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax([]),
            rightParen: .rightParenToken()
        )
        return CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(syntax))
    }

    private func makeRow(variable: String) -> CodeBlockItemSyntax {
        let variableSyntax = DeclReferenceExprSyntax(
            leadingTrivia: Trivia(pieces: [.newlines(1), .spaces(2 * spacing)]),
            baseName: .identifier(variable)
        )
        let assignmentSyntax = AssignmentExprSyntax(
            leadingTrivia: .space,
            equal: .equalToken(),
            trailingTrivia: .space
        )
        let nilSyntax = NilLiteralExprSyntax()
        let syntax = SequenceExprSyntax(
            elements: ExprListSyntax([
                ExprSyntax(variableSyntax),
                ExprSyntax(assignmentSyntax),
                ExprSyntax(nilSyntax),
            ])
        )
        return CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(syntax))
    }

    private func firstIndex(node: ClassDeclSyntax, staticMethodName: String) -> SyntaxChildrenIndex? {
        return node.memberBlock.members.firstIndex(where: { node in
            isStaticMethod(node, name: staticMethodName)
        })
    }

    private func firstIndex(node: ClassDeclSyntax, methodName: String) -> SyntaxChildrenIndex? {
        return node.memberBlock.members.firstIndex(where: { node in
            isMethod(node, name: methodName)
        })
    }

    private func isTearDownMethod(_ member: MemberBlockItemSyntax) -> Bool {
        return isMethod(member, name: "tearDown")
    }

    private func isStaticMethod(_ member: MemberBlockItemSyntax, name: String) -> Bool {
        guard let function = member.decl.as(FunctionDeclSyntax.self) else {
            return false
        }

        if function.modifiers.contains(where: { $0.name.text == "static" }) == true {
            return false
        }

        return isMethod(member, name: name)
    }

    private func isMethod(_ member: MemberBlockItemSyntax, name: String) -> Bool {
        guard let function = member.decl.as(FunctionDeclSyntax.self) else {
            return false
        }

        return function.name.text == name
    }
}
