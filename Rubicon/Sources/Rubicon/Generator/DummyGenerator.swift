final class DummyGenerator {
    private let protocolGenerator: ProtocolGenerator
    private let variableGenerator: VariableGenerator
    private let functionGenerator: FunctionGenerator
    private let initGenerator: InitGenerator

    init(
        protocolGenerator: ProtocolGenerator,
        variableGenerator: VariableGenerator,
        functionGenerator: FunctionGenerator,
        initGenerator: InitGenerator
    ) {
        self.protocolGenerator = protocolGenerator
        self.variableGenerator = variableGenerator
        self.functionGenerator = functionGenerator
        self.initGenerator = initGenerator
    }

    func generate(from protocolType: ProtocolDeclaration) -> String {
        let content = generateBody(from: protocolType)
        return protocolGenerator.makeProtocol(
            from: protocolType,
            stub: "Dummy",
            content: content
        ).joined(separator: "\n") + "\n"
    }

    private func generateBody(from protocolType: ProtocolDeclaration) -> [String] {
        var content = [[String]]()

        content.append(protocolType.variables.flatMap {
            variableGenerator.makeStubCode(
                from: $0,
                getContent: ["fatalError()"],
                setContent: ["fatalError()"]
            )
        })
        content.append(initGenerator.makeCode(with: []))

        content += protocolType.functions.map {
            return functionGenerator.makeCode(from: $0, content: ["fatalError()"])
        }

        let normalizedContent = content.filter({ !$0.isEmpty })
        return Array(normalizedContent.joined(separator: [""]))
    }
}
