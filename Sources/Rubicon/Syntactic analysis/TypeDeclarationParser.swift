import SwiftParser
import SwiftSyntax

protocol TypeDeclarationParser {
    func parse(node: TypeSyntax) -> TypeDeclaration
}

enum TypeDeclarationParserError: Error {
    case missingDeclaration
}

final class TypeDeclarationParserImpl: TypeDeclarationParser {
    func parse(node: TypeSyntax) -> TypeDeclaration {
        if let attributedType = node.as(AttributedTypeSyntax.self) {
            return TypeDeclaration(
                name: attributedType.baseType.description.trimmingCharacters(in: .whitespacesAndNewlines),
                isOptional: isOptional(node: node),
                prefix: attributedType.attributes.compactMap(makePrefix(from:))
            )
        } else {
            return TypeDeclaration(
                name: node.description.trimmingCharacters(in: .whitespacesAndNewlines),
                isOptional: isOptional(node: node),
                prefix: []
            )
        }

    }

    private func isOptional(node: TypeSyntax) -> Bool {
        let isSimpleOptional = node.as(OptionalTypeSyntax.self) != nil
        let isClosureOptional = node.as(FunctionTypeSyntax.self)?.returnClause.type.as(OptionalTypeSyntax.self) != nil
        return isSimpleOptional || isClosureOptional
    }

    private func makePrefix(from node: AttributeListSyntax.Element) -> TypeDeclaration.Prefix? {
        switch node {
        case .attribute(let attributeSyntax):
            guard let identifier = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self) else {
                return nil
            }

            return identifier.name.tokenKind == .identifier("escaping") ? .escaping : nil
        case .ifConfigDecl:
            return nil
        }

    }
}
