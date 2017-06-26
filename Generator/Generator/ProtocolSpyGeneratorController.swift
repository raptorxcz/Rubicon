//
//  ProtocolSpyGeneratorController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class ProtocolSpyGeneratorController {

    public init() {}

    public func generate(from protocolType: ProtocolType, visibility: String? = nil) -> String {
        var result = ""

        if let visibility = visibility {
            result += "\(visibility) "
        }

        result += "class \(protocolType.name)Spy: \(protocolType.name) {\n"
        result += generateBody(from: protocolType)
        result += "}\n"
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
            result += "\tvar _\(variable.identifier): \(variable.type.name)\(variable.type.isOptional ? "?" : "!")\n"
            result += "\tvar \(variable.identifier): \(variable.type.name)\(variable.type.isOptional ? "?" : "") {\n"
            result += "\t\tget {\n"
            result += "\t\t\treturn _\(variable.identifier)\n"
            result += "\t\t}\n"

            if !variable.isConstant {
                result += "\t\tset {\n"
                result += "\t\t\t_\(variable.identifier) = newValue\n"
                result += "\t\t}\n"
            }

            result += "\t}\n"
        }

        return result
    }

    private func generateFunctionVariables(_ function: FunctionDeclarationType) -> String {
        let argumentsTitles = function.arguments.flatMap({ $0.label?.capitalizingFirstLetter() }).joined()
        let functionName = "\(function.name)\(argumentsTitles)"

        var result = ""
        result += "\tvar \(functionName)Count = 0\n"

        if let returnType = function.returnType {
            result += "\tvar \(functionName)Return: \(returnType.name)\(returnType.isOptional ? "?" : "!")\n"
        }

        for argument in function.arguments {
            result += "\tvar \(functionName)\(argument.name.capitalizingFirstLetter()): \(argument.type.name)?\n"
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
        let argumentsTitles = function.arguments.flatMap({ $0.label?.capitalizingFirstLetter() }).joined()
        let functionName = "\(function.name)\(argumentsTitles)"
        let argumentsString = function.arguments.map(generateArgument).joined(separator: ", ")

        var returnString = ""

        if function.isThrowing {
            returnString += "throws "
        }

        if let returnType = function.returnType {
            returnString += "-> \(returnType.name)\(returnType.isOptional ? "?": "") "
        }

        result += "\tfunc \(function.name)(\(argumentsString)) \(returnString){\n"
        result += "\t\t\(functionName)Count += 1\n"

        for argument in function.arguments {
            result += "\t\t\(functionName)\(argument.name.capitalizingFirstLetter()) = \(argument.name)\n"
        }

        if function.returnType != nil {
            result += "\t\treturn \(functionName)Return\n"
        }

        result += "\t}\n"
        return result
    }

}
