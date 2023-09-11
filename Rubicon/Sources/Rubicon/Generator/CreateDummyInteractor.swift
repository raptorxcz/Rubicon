final class CreateDummyInteractor {
    private let protocolGenerator: ProtocolGenerator
    private var accessLevel: AccessLevel = .internal
    private var protocolType: ProtocolDeclaration?
    private var variableGenerator: VariableGenerator

    init(
        protocolGenerator: ProtocolGenerator,
        variableGenerator: VariableGenerator
    ) {
        self.protocolGenerator = protocolGenerator
        self.variableGenerator = variableGenerator
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
                    getContent: "fatalError()",
                    setContent: "fatalError()"
                )
            }
        }

        let initRows = generateInit(for: protocolType)

        if !initRows.isEmpty {
            content.append("")
            content += initRows
        }

        let body = generateFunctionsBody(for: protocolType)
        if !body.isEmpty {
            content.append("")
            content += body
        }

        return content
    }

    private func generateInit(for type: ProtocolDeclaration) -> [String] {
        guard accessLevel == .public else {
            return []
        }

        var result = [String]()
        result.append("\t\(accessLevel.makeContentString())init() {")
        result.append("\t}")
        return result
    }

    private func generateFunctionsBody(for protocolType: ProtocolDeclaration) -> [String] {
        var rows = [[String]]()

        for function in protocolType.functions {
            rows.append(generateDummy(of: function))
        }

        return rows.joined(separator: [""]).compactMap({ $0 })
    }

    private func makeArgument(from variable: VarDeclaration) -> String? {
        if variable.type.isOptional {
            return nil
        } else {
            let typeString = TypeStringFactory.makeInitString(variable.type)
            return "\(variable.identifier): \(typeString)"
        }
    }

    private func makeAssigment(of variable: VarDeclaration) -> String? {
        if variable.type.isOptional {
            return nil
        } else {
            return "\t\tself.\(variable.identifier) = \(variable.identifier)"
        }
    }

    private func makeReturnArgument(of function: FunctionDeclaration) -> String? {
        guard let returnType = function.returnType, !returnType.isOptional else {
            return nil
        }
        let functionName = getName(from: function)
        let typeString = TypeStringFactory.makeInitString(returnType)
        return "\(functionName)Return: \(typeString)"
    }

    private func makeReturnAssigment(of function: FunctionDeclaration) -> String? {
        guard let returnType = function.returnType, !returnType.isOptional else {
            return nil
        }
        let functionName = getName(from: function)

        return "\t\tself.\(functionName)Return = \(functionName)Return"
    }

    private func getName(from function: FunctionDeclaration) -> String {
        let argumentsTitles = function.arguments.map(getArgumentName(from:)).joined()
        let arguments = isFunctionNameUnique(function) ? argumentsTitles : ""

        return "\(function.name)\(arguments)"
    }

    private func getArgumentName(from type: ArgumentDeclaration) -> String {
        if let label = type.label, label != "_" {
            return label.capitalizingFirstLetter()
        } else {
            return type.name.capitalizingFirstLetter()
        }
    }

    private func isFunctionNameUnique(_ function: FunctionDeclaration) -> Bool {
        guard let protocolType = protocolType else {
            return false
        }

        var matchCount = 0

        for fc in protocolType.functions {
            if fc.name == function.name {
                matchCount += 1
            }
        }

        return matchCount > 1
    }

    private func generateArgument(_ argument: ArgumentDeclaration) -> String {
        let labelString: String

        if let label = argument.label {
            labelString = "\(label) "
        } else {
            labelString = ""
        }
        let typeString = TypeStringFactory.makeFunctionArgumentString(argument.type)
        return "\(labelString)\(argument.name): \(typeString)"
    }

    private func generateDummy(of function: FunctionDeclaration) -> [String] {
        var result = [String]()
        let argumentsString = function.arguments.map(generateArgument).joined(separator: ", ")
        var returnString = ""

        if function.isAsync {
            returnString += "async "
        }

        if function.isThrowing {
            returnString += "throws "
        }

        if let returnType = function.returnType {
            let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
            returnString += "-> \(returnTypeString) "
        }

        result.append("\t\(accessLevel.makeContentString())func \(function.name)(\(argumentsString)) \(returnString){")
        result.append("\t\tfatalError()")
        result.append("\t}")
        return result
    }
}
