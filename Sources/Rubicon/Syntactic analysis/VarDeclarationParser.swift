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
            isConstant: isLetConstant(token: node.bindingSpecifier) || isReadOnly(binding: binding),
            identifier: binding.pattern.description,
            type: type
        )
    }

    private func isLetConstant(token: TokenSyntax) -> Bool {
        switch token.tokenKind {
        case .keyword(.let):
            return true
        default:
            return false
        }
    }

    private func isReadOnly(binding: PatternBindingSyntax) -> Bool {
        guard let accessorBlock = binding.accessorBlock else {
            return false
        }

        switch accessorBlock.accessors {
        case .accessors(let list):
            guard let item = list.first else {
                return false
            }

            return item.accessorSpecifier.tokenKind == TokenKind.keyword(.get) && list.count == 1
        default:
            return false
        }
    }
}
