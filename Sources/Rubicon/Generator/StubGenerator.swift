final class StubGenerator {
    private let protocolGenerator: ProtocolGenerator
    private let variableGenerator: VariableGenerator
    private let functionGenerator: FunctionGenerator
    private let functionNameGenerator: FunctionNameGenerator
    private let initGenerator: InitGenerator
    private var isInitWithOptionalsEnabled: Bool = false

    init(
        protocolGenerator: ProtocolGenerator,
        variableGenerator: VariableGenerator,
        functionGenerator: FunctionGenerator,
        functionNameGenerator: FunctionNameGenerator,
        initGenerator: InitGenerator
    ) {
        self.protocolGenerator = protocolGenerator
        self.variableGenerator = variableGenerator
        self.functionGenerator = functionGenerator
        self.functionNameGenerator = functionNameGenerator
        self.initGenerator = initGenerator
    }

    func generate(from protocolType: ProtocolDeclaration, nameSuffix: String, isInitWithOptionalsEnabled: Bool) -> String {
        self.isInitWithOptionalsEnabled = isInitWithOptionalsEnabled
        let content = generateBody(from: protocolType)
        return protocolGenerator.makeProtocol(
            from: protocolType,
            stub: nameSuffix,
            content: content
        ).joined(separator: "\n") + "\n"
    }

    private func generateBody(from protocolType: ProtocolDeclaration) -> [String] {
        var content = [[String]]()

        content.append(makeVariables(from: protocolType).map(variableGenerator.makeCode))
        let initVariables = makeVariables(from: protocolType)
        let nonOptionalInitVariables = initVariables.filter { !$0.type.isOptional }
        content.append(initGenerator.makeCode(
            with:  isInitWithOptionalsEnabled ? initVariables : nonOptionalInitVariables,
            isAddingDefaultValueToOptionalsEnabled: isInitWithOptionalsEnabled
        ))

        content += protocolType.functions.map {
            makeFunction(from: $0, protocolDeclaration: protocolType)
        }

        let normalizedContent = content.filter({ !$0.isEmpty })
        return Array(normalizedContent.joined(separator: [""]))
    }

    private func makeVariables(from declaration: ProtocolDeclaration) -> [VarDeclaration] {
        return declaration.variables.map(makeStubVariable) + declaration.functions.flatMap { makeFunctionReturnVariable(from: $0, protocolDeclaration: declaration) }
    }

    private func makeStubVariable(from declaration: VarDeclaration) -> VarDeclaration {
        return VarDeclaration(
            isConstant: false,
            identifier: declaration.identifier,
            type: declaration.type
        )
    }

    private func makeFunctionReturnVariable(from declaration: FunctionDeclaration, protocolDeclaration: ProtocolDeclaration) -> [VarDeclaration] {
        let name = functionNameGenerator.makeUniqueName(for: declaration, in: protocolDeclaration.functions)
        var variables = [VarDeclaration]()

        if declaration.isThrowing {
            let throwBlockType = TypeDeclaration(name: "(() throws -> Void)?", isOptional: true, prefix: [.escaping])
            variables.append(VarDeclaration(isConstant: false, identifier: name + "ThrowBlock", type: throwBlockType))
        }

        if let returnType = declaration.returnType {
            variables.append(VarDeclaration(isConstant: false, identifier: name + "Return", type: returnType))
        }

        return variables
    }

    private func makeFunction(from declaration: FunctionDeclaration, protocolDeclaration: ProtocolDeclaration) -> [String] {
        var content = [String]()
        let name = functionNameGenerator.makeUniqueName(for: declaration, in: protocolDeclaration.functions)

        if declaration.isThrowing {
            content.append("try \(name)ThrowBlock?()")
        }

        if declaration.returnType != nil {
            content.append("return \(name)Return")
        }

        return functionGenerator.makeCode(from: declaration, content: content)
    }
}
