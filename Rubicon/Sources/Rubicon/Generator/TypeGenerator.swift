protocol TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String
    func makeArgumentCode(from declaration: TypeDeclaration) -> String
}

final class TypeGeneratorImpl: TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String {
        return declaration.name
    }

    func makeArgumentCode(from declaration: TypeDeclaration) -> String {
        return (declaration.prefix.map(\.rawValue) + [declaration.name]).joined(separator: " ")
    }
}
