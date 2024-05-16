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
                prefix: attributedType.attributes.compactMap(makePrefix(from:)),
                composedType: parseComposedType(from: node)
            )
        } else {
            return TypeDeclaration(
                name: node.description.trimmingCharacters(in: .whitespacesAndNewlines),
                prefix: [],
                composedType: parseComposedType(from: node)
            )
        }

    }

    private func parseComposedType(from node: TypeSyntax) -> TypeDeclaration.ComposedType {
        if isOptional(node: node) {
            return .optional
        }

        if node.is(DictionaryTypeSyntax.self) {
            return .dictionary
        }

        if isArray(node: node) {
            return .array
        }

        if isSet(node: node) {
            return .set
        }

        return .plain
    }

    private func isOptional(node: TypeSyntax) -> Bool {
        let isSimpleOptional = node.as(OptionalTypeSyntax.self) != nil
        let isClosureOptional = node.as(FunctionTypeSyntax.self)?.returnClause.type.as(OptionalTypeSyntax.self) != nil
        return isSimpleOptional || isClosureOptional
    }

    private func isArray(node: TypeSyntax) -> Bool {
        if let identifierTypeSyntax = node.as(IdentifierTypeSyntax.self) {
            return identifierTypeSyntax.name.text == "Array"
        } else {
            return node.is(ArrayTypeSyntax.self)
        }
    }

    private func isSet(node: TypeSyntax) -> Bool {
        if let identifierTypeSyntax = node.as(IdentifierTypeSyntax.self) {
            return identifierTypeSyntax.name.text == "Set"
        } else {
            return false
        }
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
