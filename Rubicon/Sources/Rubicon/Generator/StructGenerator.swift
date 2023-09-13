protocol StructGenerator {
    func makeCode(from declaration: StructDeclaration) -> [String]
}

final class StructGeneratorImpl: StructGenerator {
    private let accessLevelGenerator: AccessLevelGenerator
    private let variableGenerator: VariableGenerator
    private let indentationGenerator: IndentationGenerator

    init(
        accessLevelGenerator: AccessLevelGenerator,
        variableGenerator: VariableGenerator,
        indentationGenerator: IndentationGenerator
    ) {
        self.accessLevelGenerator = accessLevelGenerator
        self.variableGenerator = variableGenerator
        self.indentationGenerator = indentationGenerator
    }

    func makeCode(from declaration: StructDeclaration) -> [String] {
        let variables = declaration.variables.map(variableGenerator.makeCode(from:))
        let content = variables.map(indentationGenerator.indenting)
        return [
            "\(accessLevelGenerator.makeContentAccessLevel())struct \(declaration.name) {",
        ] + content + [
            "}",
        ]
    }
}
