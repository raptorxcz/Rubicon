protocol StructStubGenerator {
    func generate(from structType: StructDeclaration, functionName: String) -> String
}

final class StructStubGeneratorImpl: StructStubGenerator {
    private let extensionGenerator: ExtensionGenerator
    private let functionGenerator: FunctionGenerator
    private let indentationGenerator: IndentationGenerator
    private let defaultValueGenerator: DefaultValueGenerator

    init(
        extensionGenerator: ExtensionGenerator,
        functionGenerator: FunctionGenerator,
        indentationGenerator: IndentationGenerator,
        defaultValueGenerator: DefaultValueGenerator
    ) {
        self.extensionGenerator = extensionGenerator
        self.functionGenerator = functionGenerator
        self.indentationGenerator = indentationGenerator
        self.defaultValueGenerator = defaultValueGenerator
    }

    func generate(from structType: StructDeclaration, functionName: String) -> String {
        let content = generateBody(from: structType, functionName: functionName)
        return extensionGenerator.make(
            name: structType.name,
            content: content
        ).joined(separator: "\n") + "\n"
    }

    private func generateBody(from structType: StructDeclaration, functionName: String) -> [String] {
        let content = makeContent(from: structType)
        let functionDeclaration = FunctionDeclaration(
            name: functionName,
            arguments: structType.variables.map(makeArgument),
            isThrowing: false,
            isAsync: false,
            isStatic: true,
            returnType: TypeDeclaration(name: structType.name, prefix: [], composedType: .plain)
        )
        return functionGenerator.makeCode(
            from: functionDeclaration,
            content: content,
            isEachArgumentOnNewLineEnabled: true
        )
    }

    private func makeContent(from structType: StructDeclaration) -> [String] {
        let variables = structType.variables.enumerated().map{ makeAssigment(of: $1, isLast: $0 == structType.variables.endIndex - 1) }

        guard !variables.isEmpty else {
            return ["return \(structType.name)()"]
        }

        return [
            "return \(structType.name)("
        ] + variables.map(indentationGenerator.indenting) + [
            ")"
        ]
    }

    private func makeAssigment(of variable: VarDeclaration, isLast: Bool) -> String {
        return "\(variable.identifier): \(variable.identifier)\(isLast ? "" : ",")"
    }

    private func makeArgument(from varDeclaration: VarDeclaration) -> ArgumentDeclaration {
        ArgumentDeclaration(
            name: varDeclaration.identifier,
            type: varDeclaration.type,
            defaultValue: defaultValueGenerator.makeDefaultValue(for: varDeclaration)
        )
    }
}
