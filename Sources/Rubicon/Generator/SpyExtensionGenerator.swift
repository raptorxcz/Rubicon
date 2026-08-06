final class SpyExtensionGenerator {
    private let extensionGenerator: ExtensionGenerator
    private let indentationGenerator: IndentationGenerator
    private let functionGenerator: FunctionGenerator
    private let functionNameGenerator: FunctionNameGenerator
    private let accessLevelGenerator: AccessLevelGenerator
    private let typeGenerator: TypeGenerator
    private var isInitWithOptionalsEnabled: Bool = false

    init(
        extensionGenerator: ExtensionGenerator,
        functionGenerator: FunctionGenerator,
        indentationGenerator: IndentationGenerator,
        functionNameGenerator: FunctionNameGenerator,
        accessLevelGenerator: AccessLevelGenerator,
        typeGenerator: TypeGenerator
    ) {
        self.extensionGenerator = extensionGenerator
        self.indentationGenerator = indentationGenerator
        self.functionGenerator = functionGenerator
        self.functionNameGenerator = functionNameGenerator
        self.accessLevelGenerator = accessLevelGenerator
        self.typeGenerator = typeGenerator
    }

    func generate(from protocolType: ProtocolDeclaration, isInitWithOptionalsEnabled: Bool) -> String {
        self.isInitWithOptionalsEnabled = isInitWithOptionalsEnabled
        return extensionGenerator.make(
            name: protocolType.name + "Spy",
            content: makeSpyFunction(from: protocolType)
        ).joined(separator: "\n") + "\n"
    }

    private func makeSpyFunction(from protocolType: ProtocolDeclaration) -> [String] {
        let initVariables = makeVariables(from: protocolType) + makeReturnVariables(from: protocolType)
        let nonOptionalInitVariables = initVariables.filter { $0.type.composedType != .optional }

        let content = [
            "return \(protocolType.name)Spy(",
        ] +
            makeInitVariables(variables: isInitWithOptionalsEnabled ? initVariables : nonOptionalInitVariables)
        + [
            ")"
        ]
        let functionDeclaration = FunctionDeclaration(
            name: "makeSpy",
            arguments: makeInitArguments(
                from: isInitWithOptionalsEnabled ? initVariables : nonOptionalInitVariables,
                isAddingDefaultValueToOptionalsEnabled: isInitWithOptionalsEnabled
            ),
            // structType.variables.map(makeArgument),
            throwing: .none,
            isAsync: false,
            isStatic: true,
            returnType: TypeDeclaration(name: protocolType.name + "Spy", prefix: [], composedType: .plain)
        )
        return functionGenerator.makeCode(
            from: functionDeclaration,
            content: content,
            isEachArgumentOnNewLineEnabled: true
        )
    }

    private func makeInitVariables(variables: [VarDeclaration]) -> [String] {
        variables.enumerated().map { index, element in
            indentationGenerator.indenting(
                element.identifier + ": " + element.identifier + (index == variables.count - 1 ?  "" : ",")
            )
        }
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

        switch declaration.throwing {
        case .generic:
            let throwBlockType = TypeDeclaration(
                name: "(() throws -> Void)?",
                prefix: [.escaping],
                composedType: .optional
            )
            variables.append(VarDeclaration(isConstant: false, identifier: name + "ThrowBlock", type: throwBlockType))
        case let .specific(specificType):
            let throwBlockType = TypeDeclaration(
                name: "(() throws(\(typeGenerator.makeVariableCode(from: specificType))) -> Void)?",
                prefix: [.escaping],
                composedType: .optional
            )
            variables.append(VarDeclaration(isConstant: false, identifier: name + "ThrowBlock", type: throwBlockType))
        case .none:
            break
        }

        if let returnType = declaration.returnType {
            variables.append(VarDeclaration(isConstant: false, identifier: name + "Return", type: returnType))
        }

        return variables
    }

    func makeInitArguments(from variables: [VarDeclaration], isAddingDefaultValueToOptionalsEnabled: Bool) -> [ArgumentDeclaration] {
        return variables.map { makeInitArgument(
            from: $0,
            isAddingDefaultValueToOptionalsEnabled: isAddingDefaultValueToOptionalsEnabled
        ) }
    }

    private func makeInitArgument(from variable: VarDeclaration, isAddingDefaultValueToOptionalsEnabled: Bool) -> ArgumentDeclaration {
        let defaultValue = isAddingDefaultValueToOptionalsEnabled && variable.type.composedType == .optional ? "nil" : nil
        let prefix = variable.type.composedType == .optional ? [] : variable.type.prefix
        let type = TypeDeclaration(
            name: variable.type.name,
            prefix: prefix,
            composedType: variable.type.composedType
        )
        return ArgumentDeclaration(name: variable.identifier, type: type, defaultValue: defaultValue)
    }
}
