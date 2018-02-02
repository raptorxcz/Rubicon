//
//  ProtocolSpyGeneratorController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class ProtocolSpyGeneratorController {

    private var protocolType: ProtocolType?

    public init() {}

    public func generate(from protocolType: ProtocolType, visibility: String? = nil) -> String {
        self.protocolType = protocolType
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

        if let throwSampleError = makeThrowSampleError(for: protocolType) {
            content.append(throwSampleError)
        }
        
        if !protocolType.variables.isEmpty {
            content.append(generateVariables(protocolType.variables))
        }

        if !protocolType.functions.isEmpty {
            content.append(generateSpyVariables(for: protocolType.functions))
        }

        let initRows = generateInit(for: protocolType)
        content += initRows

        for function in protocolType.functions {
            content.append(generateSpy(of: function))
        }

        let result: String

        if !content.isEmpty {
            result = "\n\(content.joined(separator: "\n"))"
        } else {
            result = ""
        }

        return result
    }
    
    private func makeThrowSampleError(for type: ProtocolType) -> String? {
        let isAnyFuncThrowing = type.functions.contains(where: { $0.isThrowing })
        
        if isAnyFuncThrowing {
            return """
            \tenum \(type.name)SpyError: Error {
            \t\tcase spyError
            \t}
            \ttypealias ThrowBlock = () throws -> Void
            
            """
        } else {
            return nil
        }
    }

    private func generateInit(for type: ProtocolType) -> [String] {
        let arguments = type.functions.flatMap(makeReturnArgument(of:)).joined(separator: ", ")

        guard !arguments.isEmpty else {
            return []
        }

        let bodyRows = type.functions.flatMap(makeReturnAssigment(of:))
        var result = [String]()
        result.append("\tinit(\(arguments)) {")
        result += bodyRows
        result.append("\t}")
        result.append("")
        return result
    }

    private func makeReturnArgument(of function: FunctionDeclarationType) -> String? {
        guard let returnType = function.returnType, !returnType.isOptional else {
            return nil
        }
        let functionName = getName(from: function)

        return "\(functionName)Return: \(returnType.makeString())"
    }

    private func makeReturnAssigment(of function: FunctionDeclarationType) -> String? {
        guard let returnType = function.returnType, !returnType.isOptional else {
            return nil
        }
        let functionName = getName(from: function)

        return "\t\tself.\(functionName)Return = \(functionName)Return"
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

    private func generateSpyVariables(for functions: [FunctionDeclarationType]) -> String {
        var result = ""

        for function in functions {
            if !function.arguments.isEmpty {
                result += generateStruct(for: function) + "\n"
            }
        }

        for function in functions {
            result += generateFunctionVariables(function) + "\n"
        }

        return result
    }

    private func generateFunctionVariables(_ function: FunctionDeclarationType) -> String {
        let functionName = getName(from: function)

        var result = ""

        if function.arguments.isEmpty {
            result += "\tvar \(functionName)Count = 0"
        } else {
            result += generateCallStackVariable(for: function)
        }
        
        if function.isThrowing {
            result += "\n\tvar \(functionName)ThrowBlock: ThrowBlock?"
        }

        if let returnType = function.returnType {
            result += "\n\tvar \(functionName)Return: \(returnType.name)\(returnType.isOptional ? "?" : "")"
        }

        return result
    }

    private func generateCallStackVariable(for function: FunctionDeclarationType) -> String {
        let functionName = getName(from: function)
        let structName = makeStructName(from: function)
        return "\tvar \(functionName) = [\(structName)]()"
    }

    private func generateStruct(for function: FunctionDeclarationType) -> String {
        let structName = makeStructName(from: function)

        var result = ""
        result += "\tstruct \(structName) {\n"
        result += function.arguments.map(makeRow(for:)).joined()
        result += "\t}\n"
        return result
    }

    private func makeRow(for argument: ArgumentType) -> String {
        return "\t\tlet \(argument.name): \(argument.type.makeString())\n"
    }

    private func getName(from function: FunctionDeclarationType) -> String {
        let argumentsTitles = function.arguments.map(getArgumentName(from:)).joined()
        let arguments = isFunctionNameUnique(function) ? argumentsTitles : ""

        return "\(function.name)\(arguments)"
    }

    private func getArgumentName(from type: ArgumentType) -> String {
        if let label = type.label, label != "_" {
            return label.capitalizingFirstLetter()
        } else {
            return type.name.capitalizingFirstLetter()
        }
    }

    private func isFunctionNameUnique(_ function: FunctionDeclarationType) -> Bool {
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

        if function.isThrowing {
            functionBody.append("try \(functionName)ThrowBlock?()")
        }
        
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

        if function.isThrowing {
            functionBody.append("try \(functionName)ThrowBlock?()")
        }
        
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
            returnString += "-> \(returnType.name)\(returnType.isOptional ? "?" : "") "
        }

        result += "\tfunc \(function.name)(\(argumentsString)) \(returnString){\n"
        result += body.map({ "\t\t\($0)\n" }).joined()
        result += "\t}\n"
        return result
    }

    private func makeStructName(from function: FunctionDeclarationType) -> String {
        return getName(from: function).capitalizingFirstLetter()
    }
}
