import SwiftParser
import SwiftSyntax

public protocol StructParser {
    func parse(text: String) throws -> [StructDeclaration]
}

final class StructParserImpl: StructParser {
    private let varParser: VarDeclarationParser

    init(
        varParser: VarDeclarationParser
    ) {
        self.varParser = varParser
    }

    func parse(text: String) throws -> [StructDeclaration] {
        let text = SwiftParser.Parser.parse(source: text)
        let visitor = StructVisitor(
            varParser: varParser,
            nestedInItemsNames: []
        )
        return visitor.execute(node: text)
    }
}
 
private class StructVisitor: SyntaxVisitor {
    private let varParser: VarDeclarationParser
    private var result = [StructDeclaration]()
    private var nestedInItemsNames: [String]

    public init(
        varParser: VarDeclarationParser,
        nestedInItemsNames: [String]
    ) {
        self.varParser = varParser
        self.nestedInItemsNames = nestedInItemsNames
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [StructDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let varsVisitor = VariablesVisitor(varParser: varParser)
        let name = node.name.text

        result.append(
            StructDeclaration(
                name: (nestedInItemsNames + [name]).joined(separator: "."),
                variables: varsVisitor.execute(node: node),
                notes: node.leadingTrivia.pieces.compactMap(makeLineComment), 
                accessLevel: parseAccessLevel(from: node)
            )
        )

        let subVisitor = StructVisitor(varParser: varParser, nestedInItemsNames: nestedInItemsNames + [name])
        result += subVisitor.execute(node: node.memberBlock.members)

        return .skipChildren
    }

    private func parseAccessLevel(from node: StructDeclSyntax) -> AccessLevel {
        let modifiers = node.modifiers.map { $0.name.tokenKind }

        if modifiers.contains(.keyword(.public)) {
            return .public
        } else if modifiers.contains(.keyword(.private)) {
            return .private
        } else {
            return .internal
        }
    }

    private func makeLineComment(from triviaPiece: TriviaPiece) -> String? {
        switch triviaPiece {
        case .lineComment(let text):
            text
        default:
            nil
        }
    }

    private func parseParent(from inheridedTypeSyntax: InheritedTypeSyntax) -> String? {
        guard let type = inheridedTypeSyntax.type.as(IdentifierTypeSyntax.self) else {
            return nil
        }

        return type.name.text
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let name = node.name.text
        let subVisitor = StructVisitor(varParser: varParser, nestedInItemsNames: nestedInItemsNames + [name])
        result += subVisitor.execute(node: node.memberBlock.members)
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        let name = node.name.text
        let subVisitor = StructVisitor(varParser: varParser, nestedInItemsNames: nestedInItemsNames + [name])
        result += subVisitor.execute(node: node.memberBlock.members)
        return .skipChildren
    }
}

private class VariablesVisitor: SyntaxVisitor {
    private let varParser: VarDeclarationParser
    private var result = [VarDeclaration]()

    public init(varParser: VarDeclarationParser) {
        self.varParser = varParser
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [VarDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        do {
            let declaration = try varParser.parse(node: node)
            result.append(declaration)
        } catch {}
        return .visitChildren
    }
}
