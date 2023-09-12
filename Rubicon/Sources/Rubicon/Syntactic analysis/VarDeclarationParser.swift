import SwiftParser
import SwiftSyntax

protocol VarDeclarationParser {
    func parse(node: VariableDeclSyntax) throws -> VarDeclaration
}

enum VarDeclarationError: Error {
    case missingDeclaration
}

final class VarDeclarationParserImpl: VarDeclarationParser {
    private let typeDeclarationParser: TypeDeclarationParser

    public init(typeDeclarationParser: TypeDeclarationParser) {
        self.typeDeclarationParser = typeDeclarationParser
    }

    func parse(node: VariableDeclSyntax) throws -> VarDeclaration {
        guard let binding = node.bindings.first else {
            throw VarDeclarationError.missingDeclaration
        }

        guard let typeAnnotation = binding.typeAnnotation else {
            throw VarDeclarationError.missingDeclaration
        }

        let type = typeDeclarationParser.parse(node: typeAnnotation.type)

        return VarDeclaration(
            prefix: nil,
            isConstant: isConstant(token: node.bindingSpecifier),
            identifier: binding.pattern.description,
            type: type
        )
    }

    private func isConstant(token: TokenSyntax) -> Bool {
        switch token.tokenKind {
        case .keyword(.let):
            return true
        default:
            return false
        }
    }
}
