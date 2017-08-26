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
            content.append(generateSpy(of: function))
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
        let functionName = makeName(from: function)

        var result = ""
        
        if function.arguments.isEmpty {
            result += "\tvar \(functionName)Count = 0\n"
        } else {
            result += generateStruct(for: function)
        }

        if let returnType = function.returnType {
            result += "\tvar \(functionName)Return: \(returnType.name)\(returnType.isOptional ? "?" : "!")\n"
        }

        return result
    }
    
    private func generateStruct(for function: FunctionDeclarationType) -> String {
        let functionName = getName(from: function)
        let structName = makeStructName(from: function)
        
        var result = ""
        result += "\tstruct \(structName) {\n"
        result += function.arguments.map(makeRow(for:)).joined()
        result += "\t}\n"
        result += "\tvar \(functionName) = [\(structName)]()\n"
        
        return result
    }
    
    private func makeRow(for argument: ArgumentType) -> String {
        return "\t\tlet \(argument.name): \(argument.type.makeString())\n"
    }

    private func getName(from function: FunctionDeclarationType) -> String {
        let argumentsTitles = function.arguments.map(getArgumentName(from:)).joined()
        return "\(function.name)\(argumentsTitles)"
    }
    
    private func getArgumentName(from type: ArgumentType) -> String {
        if let label = type.label, label != "_" {
            return label.capitalizingFirstLetter()
        } else {
            return type.name.capitalizingFirstLetter()
        }
    }
    
    private func makeName(from function: FunctionDeclarationType) -> String {
        let argumentsTitles = function.arguments.map({ $0.label?.capitalizingFirstLetter() ?? $0.name.capitalizingFirstLetter() }).joined()
        return "\(function.name)\(argumentsTitles)"
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

    private func generateSpy(of function: FunctionDeclarationType) -> String {
        if function.arguments.isEmpty {
            return generateSpyWithoutArguments(of: function)
        } else {
            return generateSpyWithArguments(of: function)
        }
    }
    
    private func generateSpyWithoutArguments(of function: FunctionDeclarationType) -> String {
        let functionName = getName(from: function)
        var functionBody = [String]()
        
        functionBody.append("\(functionName)Count += 1")
        
        if function.returnType != nil {
            functionBody.append("return \(functionName)Return")
        }
        
        return makeFunctionDefinition(of: function, body: functionBody)
    }
    
    private func generateSpyWithArguments(of function: FunctionDeclarationType) -> String {
        let functionName = getName(from: function)
        let structName = makeStructName(from: function)
        
        var functionBody = [String]()
        let argumentList = function.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", ")
        
        functionBody.append("let item = \(structName)(\(argumentList))")
        functionBody.append("\(functionName).append(item)")
        
        if function.returnType != nil {
            functionBody.append("return \(functionName)Return")
        }
        
        return makeFunctionDefinition(of: function, body: functionBody)
    }
    
    private func makeFunctionDefinition(of function: FunctionDeclarationType, body: [String]) -> String {
        var result = ""
        let argumentsString = function.arguments.map(generateArgument).joined(separator: ", ")
        var returnString = ""
        
        if function.isThrowing {
            returnString += "throws "
        }
        
        if let returnType = function.returnType {
            returnString += "-> \(returnType.name)\(returnType.isOptional ? "?": "") "
        }
        
        result += "\tfunc \(function.name)(\(argumentsString)) \(returnString){\n"
        result += body.map({"\t\t\($0)\n"}).joined()
        result += "\t}\n"
        return result
    }
    
    private func makeStructName(from function: FunctionDeclarationType) -> String {
        return getName(from: function).capitalizingFirstLetter()
    }

}
