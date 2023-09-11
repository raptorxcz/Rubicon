protocol VariableGenerator {
    func makeStubCode(from declaration: VarDeclaration, getContent: String, setContent: String) -> String
}

final class VariableGeneratorImpl: VariableGenerator {
    private let typeGenerator: TypeGenerator
    private let accessLevelGenerator: AccessLevelGenerator

    init(
        typeGenerator: TypeGenerator,
        accessLevelGenerator: AccessLevelGenerator
    ) {
        self.typeGenerator = typeGenerator
        self.accessLevelGenerator = accessLevelGenerator
    }

    func makeStubCode(from declaration: VarDeclaration, getContent: String, setContent: String) -> String {
        if declaration.isConstant {
            return """
            \t\(accessLevelGenerator.makeContentAccessLevel())var \(declaration.identifier): \(typeGenerator.makeVariableCode(from: declaration.type)) {
            \t\tget {
            \(getContent)
            \t\t}
            \t}
            """
        } else {
            return """
            \t\(accessLevelGenerator.makeContentAccessLevel())var \(declaration.identifier): \(typeGenerator.makeVariableCode(from: declaration.type)) {
            \t\tget {
            \(getContent)
            \t\t}
            \t\tset {
            \(setContent)
            \t\t}
            \t}
            """
        }
    }
}
