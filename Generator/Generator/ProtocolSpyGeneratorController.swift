//
//  ProtocolSpyGeneratorController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class ProtocolSpyGeneratorController {

    public init() {}

    public func generate(from protocolType: ProtocolType) -> String {
        var result = ""
        result += "class \(protocolType.name)Spy: \(protocolType.name) {\n"
        result += generateBody(from: protocolType)
        result += "}\n\n"
        return result
    }

    private func generateBody(from protocolType: ProtocolType) -> String {
        var content = [String]()

        if !protocolType.variables.isEmpty {
            content.append(generateVariables(protocolType.variables))
        }

        for function in protocolType.functions {
            content.append(generateFunctionVariables(function))
        }

        for function in protocolType.functions {
            content.append(generateFunctionDefinitions(function))
        }

        let result: String

        if !content.isEmpty {
            result = "\n\(content.joined(separator: "\n"))\n"
        } else {
            result = ""
        }

        return result
    }

    private func generateVariables(_ variables: [VarDeclarationType]) -> String {
        var result = ""

        for variable in variables {
            result += "var \(variable.identifier): \(variable.type.name)!\n"
        }

        return result
    }

    private func generateFunctionVariables(_ function: FunctionDeclarationType) -> String {
        let argumentsTitles = function.arguments.flatMap({ $0.label?.capitalized }).joined()
        let functionName = "\(function.name)\(argumentsTitles)"

        var result = ""
        result += "var \(functionName)Count = 0\n"

        for argument in function.arguments {
            result += "var \(functionName)\(argument.name.capitalized): \(argument.type.name)?\n"
        }

        return result
    }

    private func generateArgument(_ argument: ArgumentType) -> String {
        let labelString: String

        if let label = argument.label {
            labelString = "\(label) "
        } else {
            labelString = ""
        }

        let optionalLabel = argument.type.isOptional ? "?" : ""
        return "\(labelString)\(argument.name): \(argument.type.name)\(optionalLabel)"
    }

    private func generateFunctionDefinitions(_ function: FunctionDeclarationType) -> String {
        var result = ""
        let argumentsTitles = function.arguments.flatMap({ $0.label?.capitalized }).joined()
        let functionName = "\(function.name)\(argumentsTitles)"
        let argumentsString = function.arguments.map(generateArgument).joined(separator: ", ")

        result += "func \(function.name)(\(argumentsString)) {\n"
        result += "\(functionName)Count += 1\n"

        for argument in function.arguments {
            result += "\(functionName)\(argument.name.capitalized) = \(argument.name)\n"
        }

        result += "}\n"
        return result
    }

}
