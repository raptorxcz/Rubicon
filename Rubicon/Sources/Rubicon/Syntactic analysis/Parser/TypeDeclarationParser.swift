import SwiftParser
import SwiftSyntax

protocol TypeDeclarationParser {
    func parse(node: TypeSyntax) throws -> TypeDeclaration
}

enum TypeDeclarationParserError: Error {
    case missingDeclaration
}

final class TypeDeclarationParserImpl: TypeDeclarationParser {
    func parse(node: TypeSyntax) throws -> TypeDeclaration {
        return TypeDeclaration(
            name: node.description,
            isOptional: isOptional(node: node)
        )
    }

    private func isOptional(node: TypeSyntax) -> Bool {
        let isSimpleOptional = node.as(OptionalTypeSyntax.self) != nil
        let isClosureOptional = node.as(FunctionTypeSyntax.self)?.returnClause.type.as(OptionalTypeSyntax.self) != nil
        return isSimpleOptional || isClosureOptional
    }
}
