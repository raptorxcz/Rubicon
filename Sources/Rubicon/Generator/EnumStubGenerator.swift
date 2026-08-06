public protocol EnumStubGenerator {
    func generate(from enumType: EnumDeclaration, functionName: String) -> String
}

final class EnumStubGeneratorImpl: EnumStubGenerator {
    private let extensionGenerator: ExtensionGenerator
    private let functionGenerator: FunctionGenerator
    private let indentationGenerator: IndentationGenerator
    private let target: String?

    init(
        extensionGenerator: ExtensionGenerator,
        functionGenerator: FunctionGenerator,
        indentationGenerator: IndentationGenerator,
        target: String?
    ) {
        self.extensionGenerator = extensionGenerator
        self.functionGenerator = functionGenerator
        self.indentationGenerator = indentationGenerator
        self.target = target
    }

    func generate(from enumType: EnumDeclaration, functionName: String) -> String {
        let content = generateBody(from: enumType, functionName: functionName)
        return extensionGenerator.make(
            name: (target.map {  "\($0)::" } ?? "") + enumType.name,
            content: content
        ).joined(separator: "\n") + "\n"
    }

    private func generateBody(from enumType: EnumDeclaration, functionName: String) -> [String] {
        let content = makeContent(from: enumType)
        let functionDeclaration = FunctionDeclaration(
            name: functionName,
            arguments: [],
            throwing: .none,
            isAsync: false,
            isStatic: true,
            returnType: TypeDeclaration(name: "Self", prefix: [], composedType: .plain)
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
