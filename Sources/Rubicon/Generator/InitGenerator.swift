protocol InitGenerator {
    func makeCode(with variables: [VarDeclaration], isAddingDefaultValueToOptionalsEnabled: Bool) -> [String]
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

    func makeCode(with variables: [VarDeclaration], isAddingDefaultValueToOptionalsEnabled: Bool) -> [String] {
        let assignments = variables.map(makeAssigment(of:))

        guard !assignments.isEmpty || accessLevel == .public else {
            return []
        }

        let initArguments = variables.map { makeInitArgument(
            from: $0,
            isAddingDefaultValueToOptionalsEnabled: isAddingDefaultValueToOptionalsEnabled
        ) } .joined(separator: ", ")

        return [
            "\(accessLevelGenerator.makeContentAccessLevel())init(\(initArguments)) {"
        ] + assignments.map(indentationGenerator.indenting) + [
            "}"
        ]
    }

    private func makeAssigment(of variable: VarDeclaration) -> String {
        return "self.\(variable.identifier) = \(variable.identifier)"
    }

    private func makeInitArgument(from variable: VarDeclaration, isAddingDefaultValueToOptionalsEnabled: Bool) -> String {
        let defaultValue = isAddingDefaultValueToOptionalsEnabled && variable.type.isOptional ? " = nil" : ""
        let declaration = ArgumentDeclaration(name: variable.identifier, type: variable.type)
        return argumentGenerator.makeCode(from: declaration) + defaultValue
    }
}
