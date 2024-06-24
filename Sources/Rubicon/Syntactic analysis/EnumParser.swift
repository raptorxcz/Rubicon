import SwiftParser
import SwiftSyntax

public protocol EnumParser {
    func parse(text: String) throws -> [EnumDeclaration]
}

final class EnumParserImpl: EnumParser {
    func parse(text: String) throws -> [EnumDeclaration] {
        let text = SwiftParser.Parser.parse(source: text)
        let visitor = EnumVisitor(
            nestedInItemsNames: []
        )
        return visitor.execute(node: text)
    }
}
 
private class EnumVisitor: SyntaxVisitor {
    private var result = [EnumDeclaration]()
    private var nestedInItemsNames: [String]

    public init(
        nestedInItemsNames: [String]
    ) {
        self.nestedInItemsNames = nestedInItemsNames
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [EnumDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {

        let name = node.name.text

        result.append(
            EnumDeclaration(
                name: (nestedInItemsNames + [name]).joined(separator: "."),
                cases: parseCases(node: node.memberBlock),
                notes: node.leadingTrivia.pieces.compactMap(makeLineComment),
                accessLevel: parseAccessLevel(from: node)
            )
        )

        let subVisitor = EnumVisitor(nestedInItemsNames: nestedInItemsNames + [name])
        result += subVisitor.execute(node: node.memberBlock.members)

        return .skipChildren
    }

    private func parseCases(node: MemberBlockSyntax) -> [String] {
        let casesParser = CasesVisitor(viewMode: .sourceAccurate)
        return casesParser.execute(node: node.members)
    }

    private func parseAccessLevel(from node: EnumDeclSyntax) -> AccessLevel {
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
        let subVisitor = EnumVisitor(nestedInItemsNames: nestedInItemsNames + [name])
        result += subVisitor.execute(node: node.memberBlock.members)
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let name = node.name.text
        let subVisitor = EnumVisitor(nestedInItemsNames: nestedInItemsNames + [name])
        result += subVisitor.execute(node: node.memberBlock.members)
        return .skipChildren
    }
}

private class CasesVisitor: SyntaxVisitor {
    private var result = [String]()

    func execute(node: some SyntaxProtocol) -> [String] {
        walk(node)
        return result
    }

    override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        let declaration = node.elements.map(\.name.text)
        result += declaration
        return .visitChildren
    }
}
