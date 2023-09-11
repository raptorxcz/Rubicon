protocol TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String
}

final class TypeGeneratorImpl: TypeGenerator {
    func makeVariableCode(from declaration: TypeDeclaration) -> String {
        return declaration.name
    }
}
