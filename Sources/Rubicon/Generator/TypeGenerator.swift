protocol TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String
    func makeArgumentCode(from declaration: TypeDeclaration) -> String
}

final class TypeGeneratorImpl: TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String {
        let prefix = declaration.prefix.filter(isAllowed).map(\.rawValue)
        return (prefix + [declaration.name]).joined(separator: " ")
    }

    private func isAllowed(prefix: TypeDeclaration.Prefix) -> Bool {
        [TypeDeclaration.Prefix.mainActor, .sendable].contains(prefix)
    }

    func makeArgumentCode(from declaration: TypeDeclaration) -> String {
        return (declaration.prefix.map(\.rawValue) + [declaration.name]).joined(separator: " ")
    }
}
