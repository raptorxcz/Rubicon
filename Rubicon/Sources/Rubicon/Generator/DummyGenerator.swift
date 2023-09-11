final class DummyGenerator {
    private let protocolGenerator: ProtocolGenerator
    private let variableGenerator: VariableGenerator
    private let functionGenerator: FunctionGenerator
    private let accessLevel: AccessLevel
    private let accessLevelGenerator: AccessLevelGenerator

    init(
        protocolGenerator: ProtocolGenerator,
        variableGenerator: VariableGenerator,
        functionGenerator: FunctionGenerator,
        accessLevel: AccessLevel,
        accessLevelGenerator: AccessLevelGenerator
    ) {
        self.protocolGenerator = protocolGenerator
        self.variableGenerator = variableGenerator
        self.functionGenerator = functionGenerator
        self.accessLevel = accessLevel
        self.accessLevelGenerator = accessLevelGenerator
    }

    func generate(from protocolType: ProtocolDeclaration) -> String {
        let content = generateBody(from: protocolType)
        return protocolGenerator.makeProtocol(
            from: protocolType,
            stub: "Dummy",
            content: content.joined(separator: "\n")
        )
    }

    private func generateBody(from protocolType: ProtocolDeclaration) -> [String] {
        var content = [String]()

        if !protocolType.variables.isEmpty {
            content += protocolType.variables.map{
                variableGenerator.makeStubCode(
                    from: $0,
                    getContent: "\t\t\tfatalError()",
                    setContent: "\t\t\tfatalError()"
                )
            }
            content.append("")
        }

        let initRows = generateInit(for: protocolType)

        if !initRows.isEmpty {
            content.append(initRows)
        }

        content += protocolType.functions.map {
            functionGenerator.makeCode(from: $0, content: "\t\tfatalError()") + "\n"
        }

        return content
    }

    private func generateInit(for type: ProtocolDeclaration) -> String {
        guard accessLevel == .public else {
            return ""
        }

        return """
        \t\(accessLevelGenerator.makeContentAccessLevel())init() {
        \t}
        
        """
    }
}
