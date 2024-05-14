import SwiftParser
import SwiftSyntax

protocol StructParser {
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
            varParser: varParser
        )
        return visitor.execute(node: text)
    }
}
 
private class StructVisitor: SyntaxVisitor {
    private let varParser: VarDeclarationParser
    private var result = [StructDeclaration]()

    public init(
        varParser: VarDeclarationParser
    ) {
        self.varParser = varParser
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [StructDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let varsVisitor = VariablesVisitor(varParser: varParser)

        result.append(
            StructDeclaration(
                name: node.name.text,
                variables: varsVisitor.execute(node: node)
            )
        )
        return .visitChildren
    }

    private func parseParent(from inheridedTypeSyntax: InheritedTypeSyntax) -> String? {
        guard let type = inheridedTypeSyntax.type.as(IdentifierTypeSyntax.self) else {
            return nil
        }

        return type.name.text
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
