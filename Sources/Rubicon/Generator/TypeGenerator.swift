protocol TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String
    func makeArgumentCode(from declaration: TypeDeclaration) -> String
}

final class TypeGeneratorImpl: TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String {
        let prefix = declaration.prefix.filter { $0 == .mainActor }.map(\.rawValue)
        return (prefix + [declaration.name]).joined(separator: " ")
    }

    func makeArgumentCode(from declaration: TypeDeclaration) -> String {
        return (declaration.prefix.map(\.rawValue) + [declaration.name]).joined(separator: " ")
    }
}
