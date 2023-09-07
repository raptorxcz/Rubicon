//
//  NilableVariablesParser.swift
//  Generator
//
//  Created by Kryštof Matěj on 03.06.2022.
//  Copyright © 2022 Kryštof Matěj. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftParser

public protocol NilableVariablesParser {
    func parse(from node: ClassDeclSyntax) -> [String]
}

public final class NilableVariablesParserImpl: NilableVariablesParser {
    public init() {}

    public func parse(from node: ClassDeclSyntax) -> [String] {
        return node.memberBlock.members.flatMap(getNilVariable(from:))
    }

    private func getNilVariable(from member: MemberBlockItemSyntax) -> [String] {
        guard let variable = member.decl.as(VariableDeclSyntax.self) else {
            return []
        }

        guard variable.bindingSpecifier.text == "var" else {
            return []
        }

        return variable.bindings.compactMap(getVariable(for:))
    }

    private func getVariable(for node: PatternBindingSyntax) -> String? {
        let name = node.pattern.description

        if node.typeAnnotation?.type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) != nil {
            return name
        }

        if node.typeAnnotation?.type.as(OptionalTypeSyntax.self) != nil {
            return name
        }

        return nil
    }
}
