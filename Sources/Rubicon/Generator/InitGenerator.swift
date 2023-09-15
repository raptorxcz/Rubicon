protocol InitGenerator {
    func makeCode(with variables: [VarDeclaration]) -> [String]
}

final class InitGeneratorImpl: InitGenerator {
    private let accessLevel: AccessLevel
    private let accessLevelGenerator: AccessLevelGenerator
    private let indentationGenerator: IndentationGenerator
    private let argumentGenerator: ArgumentGenerator

    init(
        accessLevel: AccessLevel,
        accessLevelGenerator: AccessLevelGenerator,
        indentationGenerator: IndentationGenerator,
        argumentGenerator: ArgumentGenerator
    ) {
        self.accessLevel = accessLevel
        self.accessLevelGenerator = accessLevelGenerator
        self.indentationGenerator = indentationGenerator
        self.argumentGenerator = argumentGenerator
    }

    func makeCode(with variables: [VarDeclaration]) -> [String] {
        let assignments = variables.compactMap(makeAssigment(of:))

        guard !assignments.isEmpty || accessLevel == .public else {
            return []
        }

        let initArguments = variables.compactMap(makeInitArgument(from:)).joined(separator: ", ")

        return [
            "\(accessLevelGenerator.makeContentAccessLevel())init(\(initArguments)) {"
        ] + assignments.map(indentationGenerator.indenting) + [
            "}"
        ]
    }

    private func makeAssigment(of variable: VarDeclaration) -> String? {
        if variable.type.isOptional {
            return nil
        } else {
            return "self.\(variable.identifier) = \(variable.identifier)"
        }
    }

    private func makeInitArgument(from variable: VarDeclaration) -> String? {
        if variable.type.isOptional {
            return nil
        } else {
            let declaration = ArgumentDeclaration(name: variable.identifier, type: variable.type)
            return argumentGenerator.makeCode(from: declaration)
        }
    }
}
