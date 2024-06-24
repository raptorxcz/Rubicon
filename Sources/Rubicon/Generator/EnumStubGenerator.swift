public protocol EnumStubGenerator {
    func generate(from enumType: EnumDeclaration, functionName: String) -> String
}

final class EnumStubGeneratorImpl: EnumStubGenerator {
    private let extensionGenerator: ExtensionGenerator
    private let functionGenerator: FunctionGenerator
    private let indentationGenerator: IndentationGenerator

    init(
        extensionGenerator: ExtensionGenerator,
        functionGenerator: FunctionGenerator,
        indentationGenerator: IndentationGenerator
    ) {
        self.extensionGenerator = extensionGenerator
        self.functionGenerator = functionGenerator
        self.indentationGenerator = indentationGenerator
    }

    func generate(from enumType: EnumDeclaration, functionName: String) -> String {
        let content = generateBody(from: enumType, functionName: functionName)
        return extensionGenerator.make(
            name: enumType.name,
            content: content
        ).joined(separator: "\n") + "\n"
    }

    private func generateBody(from enumType: EnumDeclaration, functionName: String) -> [String] {
        let content = makeContent(from: enumType)
        let functionDeclaration = FunctionDeclaration(
            name: functionName,
            arguments: [],
            isThrowing: false,
            isAsync: false,
            isStatic: true,
            returnType: TypeDeclaration(name: enumType.name, prefix: [], composedType: .plain)
        )
        return functionGenerator.makeCode(
            from: functionDeclaration,
            content: content,
            isEachArgumentOnNewLineEnabled: true
        )
    }

    private func makeContent(from enumType: EnumDeclaration) -> [String] {
        let firstCase = enumType.cases.first.map { "." + $0 } ?? ""
        return [
            "return \(firstCase)"
        ]
    }
}
