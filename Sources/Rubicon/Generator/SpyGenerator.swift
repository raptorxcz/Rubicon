final class SpyGenerator {
    private let protocolGenerator: ProtocolGenerator
    private let variableGenerator: VariableGenerator
    private let functionGenerator: FunctionGenerator
    private let functionNameGenerator: FunctionNameGenerator
    private let initGenerator: InitGenerator
    private let structGenerator: StructGenerator
    private let accessLevelGenerator: AccessLevelGenerator
    private var isInitWithOptionalsEnabled: Bool = false

    init(
        protocolGenerator: ProtocolGenerator,
        variableGenerator: VariableGenerator,
        functionGenerator: FunctionGenerator,
        functionNameGenerator: FunctionNameGenerator,
        initGenerator: InitGenerator,
        structGenerator: StructGenerator,
        accessLevelGenerator: AccessLevelGenerator
    ) {
        self.protocolGenerator = protocolGenerator
        self.variableGenerator = variableGenerator
        self.functionGenerator = functionGenerator
        self.functionNameGenerator = functionNameGenerator
        self.initGenerator = initGenerator
        self.structGenerator = structGenerator
        self.accessLevelGenerator = accessLevelGenerator
    }

    func generate(from protocolType: ProtocolDeclaration, isInitWithOptionalsEnabled: Bool) -> String {
        self.isInitWithOptionalsEnabled = isInitWithOptionalsEnabled
        let content = generateBody(from: protocolType)
        return protocolGenerator.makeProtocol(
            from: protocolType,
            stub: "Spy",
            content: content
        ).joined(separator: "\n") + "\n"
    }

    private func generateBody(from protocolType: ProtocolDeclaration) -> [String] {
        var content = [[String]]()

        content += protocolType.functions.map {
            makeStruct(from: $0, protocolDeclaration: protocolType)
        }

        content.append(makeVariables(from: protocolType).map(variableGenerator.makeCode))
        content.append(makeSpyVariables(from: protocolType))
        let initVariables = makeVariables(from: protocolType) + makeReturnVariables(from: protocolType)
        let nonOptionalInitVariables = initVariables.filter { !$0.type.isOptional }
        content.append(initGenerator.makeCode(
            with: isInitWithOptionalsEnabled ? initVariables : nonOptionalInitVariables,
            isAddingDefaultValueToOptionalsEnabled: isInitWithOptionalsEnabled
        ))

        content += protocolType.functions.map {
            makeFunction(from: $0, protocolDeclaration: protocolType)
        }

        let normalizedContent = content.filter({ !$0.isEmpty })
        return Array(normalizedContent.joined(separator: [""]))
    }

    private func makeVariables(from declaration: ProtocolDeclaration) -> [VarDeclaration] {
        return declaration.variables.map(makeSpyVariable)
    }

    private func makeReturnVariables(from declaration: ProtocolDeclaration) -> [VarDeclaration] {
        return declaration.functions.flatMap { makeFunctionReturnVariable(from: $0, protocolDeclaration: declaration) }
    }

    private func makeSpyVariable(from declaration: VarDeclaration) -> VarDeclaration {
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

    private func makeSpyVariables(from declaration: ProtocolDeclaration) -> [String] {
        return makeReturnVariables(from: declaration).map(variableGenerator.makeCode) + declaration.functions.map { makeSpyVariable(from: $0, protocolDeclaration: declaration) }
    }

    private func makeSpyVariable(from declaration: FunctionDeclaration, protocolDeclaration: ProtocolDeclaration) -> String {
        let name = functionNameGenerator.makeUniqueName(for: declaration, in: protocolDeclaration.functions)

        if declaration.arguments.isEmpty {
            return "\(accessLevelGenerator.makeContentAccessLevel())var \(name)Count = 0"
        } else {
            let structName = functionNameGenerator.makeStructUniqueName(for: declaration, in: protocolDeclaration.functions)
            return "\(accessLevelGenerator.makeContentAccessLevel())var \(name) = [\(structName)]()"
        }
    }

    private func makeStruct(from declaration: FunctionDeclaration, protocolDeclaration: ProtocolDeclaration) -> [String] {
        guard !declaration.arguments.isEmpty else {
            return []
        }

        let name = functionNameGenerator.makeStructUniqueName(for: declaration, in: protocolDeclaration.functions)
        let structDeclaration = StructDeclaration(
            name: name,
            variables: declaration.arguments.map{ VarDeclaration(isConstant: true, identifier: $0.name, type: $0.type) }
        )
        return structGenerator.makeCode(from: structDeclaration)
    }

    private func makeFunction(from declaration: FunctionDeclaration, protocolDeclaration: ProtocolDeclaration) -> [String] {
        var content = [String]()
        let name = functionNameGenerator.makeUniqueName(for: declaration, in: protocolDeclaration.functions)
        let structName = functionNameGenerator.makeStructUniqueName(for: declaration, in: protocolDeclaration.functions)

        if declaration.arguments.isEmpty {
            content.append("\(name)Count += 1")
        } else {
            let arguments = declaration.arguments.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            content += [
                "let item = \(structName)(\(arguments))",
                "\(name).append(item)",
            ]
        }

        if declaration.isThrowing {
            content.append("try \(name)ThrowBlock?()")
        }

        if declaration.returnType != nil {
            content.append("return \(name)Return")
        }

        return functionGenerator.makeCode(
            from: declaration,
            content: content,
            isEachArgumentOnNewLineEnabled: false
        )
    }
}
