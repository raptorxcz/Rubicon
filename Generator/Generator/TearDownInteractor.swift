//
//  TearDownInteractor.swift
//  Generator
//
//  Created by Kryštof Matěj on 19.05.2022.
//  Copyright © 2022 Kryštof Matěj. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxParser

public final class TearDownInteractor {
    private let nilableVariablesParser: NilableVariablesParser

    public init(nilableVariablesParser: NilableVariablesParser) {
        self.nilableVariablesParser = nilableVariablesParser
    }

    public func execute(text: String, spacing: Int) throws -> String {
        let file = try SyntaxParser.parse(source: text)
        let classRewriter = ClassRewriter(
            nilableVariablesParser: nilableVariablesParser,
            spacing: spacing
        )
        return classRewriter.visit(file.root).description
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

        if let index = firstIndex(node: node, methodName: "tearDown") {
            let newMembers = node.members.members.removing(childAt: index)
            node.members = node.members.withMembers(newMembers)
        }

        let nilableVariables = nilableVariablesParser.parse(from: node)
        let tearDownMethod = makeTearDownMethod(variables: nilableVariables)

        if let index = firstIndex(node: node, methodName: "setUp") {
            let newMembers = node.members.members.inserting(tearDownMethod, at: index + 1)
            node.members = node.members.withMembers(newMembers)
        } else if let index = firstIndex(node: node, methodName: "setUpWithError") {
            let newMembers = node.members.members.inserting(tearDownMethod, at: index + 1)
            node.members = node.members.withMembers(newMembers)
        } else {
            node.members = node.members.addMember(tearDownMethod)
        }

        return super.visit(node)
    }

    private func isRelevantClass(node: ClassDeclSyntax) -> Bool {
        guard node.identifier.text.hasSuffix("Tests") else {
            return false
        }

        guard firstIndex(node: node, methodName: "tearDownWithError") == nil else {
            return false
        }

        return true
    }

    private func makeTearDownMethod(variables: [String]) -> MemberDeclListItemSyntax {
        var modifiers = SyntaxFactory.makeModifierList([
            SyntaxFactory.makeDeclModifier(name: .identifier("override"), detailLeftParen: nil, detail: nil, detailRightParen: nil),
        ])
        modifiers.trailingTrivia = .spaces(1)
        let leftBrace = SyntaxFactory.makeLeftBraceToken(leadingTrivia: .spaces(1))
        let rightBrace = SyntaxFactory.makeRightBraceToken(leadingTrivia: Trivia(pieces: [.newlines(1), .spaces(spacing)]))
        let input = SyntaxFactory.makeParameterClause(
            leftParen: .leftParen,
            parameterList: SyntaxFactory.makeFunctionParameterList([]),
            rightParen: .rightParen
        )
        let signature = SyntaxFactory.makeFunctionSignature(input: input, asyncOrReasyncKeyword: nil, throwsOrRethrowsKeyword: nil, output: nil)
        var function = SyntaxFactory.makeFunctionDecl(
            attributes: nil,
            modifiers: modifiers,
            funcKeyword: .func,
            identifier: .identifier("tearDown"),
            genericParameterClause: nil,
            signature: signature,
            genericWhereClause: nil,
            body: SyntaxFactory.makeCodeBlock(
                leftBrace: leftBrace,
                statements: SyntaxFactory.makeCodeBlockItemList([makeSuperRow()] + variables.map(makeRow)),
                rightBrace: rightBrace
            )
        )
        function.leadingTrivia = Trivia(pieces: [.newlines(2), .spaces(spacing)])
        return SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(function),
            semicolon: nil
        )
    }

    private func makeSuperRow() -> CodeBlockItemSyntax {
        var superExpression = SyntaxFactory.makeSuperRefExpr(superKeyword: .super)
        superExpression.trailingTrivia = nil
        var memberExpression = SyntaxFactory.makeMemberAccessExpr(base: ExprSyntax(superExpression), dot: .period, name: .identifier("tearDown"), declNameArguments: nil)
        memberExpression.leadingTrivia = Trivia(pieces: [.newlines(1), .spaces(2 * spacing)])
        let syntax = SyntaxFactory.makeFunctionCallExpr(
            calledExpression: ExprSyntax(memberExpression),
            leftParen: .leftParen,
            argumentList: SyntaxFactory.makeTupleExprElementList([]),
            rightParen: .rightParen,
            trailingClosure: nil,
            additionalTrailingClosures: nil
        )
        return SyntaxFactory.makeCodeBlockItem(
            item: Syntax(syntax),
            semicolon: nil,
            errorTokens: nil
        )
    }

    private func makeRow(variable: String) -> CodeBlockItemSyntax {
        let variableSyntax = SyntaxFactory.makeIdentifierExpr(identifier: SyntaxFactory.makeIdentifier(variable, leadingTrivia: Trivia(pieces: [.newlines(1), .spaces(2 * spacing)])), declNameArguments: nil)
        var assignmentSyntax = SyntaxFactory.makeAssignmentExpr(assignToken: .equal)
        assignmentSyntax.trailingTrivia = .spaces(1)
        var nilSyntax = SyntaxFactory.makeNilLiteralExpr(nilKeyword: .nil)
        nilSyntax.trailingTrivia = nil
        let syntax = SyntaxFactory.makeSequenceExpr(
            elements: SyntaxFactory.makeExprList([
                ExprSyntax(variableSyntax),
                ExprSyntax(assignmentSyntax),
                ExprSyntax(nilSyntax),
            ])
        )
        return SyntaxFactory.makeCodeBlockItem(
            item: Syntax(syntax),
            semicolon: nil,
            errorTokens: nil
        )
    }

    private func firstIndex(node: ClassDeclSyntax, methodName: String) -> Int? {
        if let (index, _) = node.members.members.enumerated().first(where: { isMethod($1, name: methodName) }) {
            return index
        } else {
            return nil
        }
    }

    private func isMethod(_ member: MemberDeclListItemSyntax, name: String) -> Bool {
        guard let function = member.decl.as(FunctionDeclSyntax.self) else {
            return false
        }

        if function.modifiers?.contains(where: { $0.name.text == "static" }) == true {
            return false
        }

        return function.identifier.text == name
    }
}
