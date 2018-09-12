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
        var result = [String]()
        result.append("\(makeVisibilityString(visibility))class \(protocolType.name)Spy: \(protocolType.name) {")
        result += generateBody(from: protocolType)
        result.append("}")

        var string = result.joined(separator: "\n")
        if !string.isEmpty {
            string.append("\n")
        }
        return string
    }

    private func makeVisibilityString(_ visibility: String?) -> String {
        if let visibility = visibility {
            return "\(visibility) "
        } else {
            return ""
        }
    }

    private func generateBody(from protocolType: ProtocolType) -> [String] {
        var content = [String]()

        if let throwSampleError = makeThrowSampleError(for: protocolType) {
            content.append("")
            content.append(throwSampleError)
        }

        if !protocolType.variables.isEmpty {
            content.append("")
            content += generateVariables(protocolType.variables)
        }

        if !protocolType.functions.isEmpty {
            content.append("")
            content += generateSpyVariables(for: protocolType.functions)
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

    private func generateFunctionsBody(for protocolType: ProtocolType) -> [String] {
        var rows = [[String]]()

        for function in protocolType.functions {
            rows.append(generateSpy(of: function))
        }

        return rows.joined(separator: [""]).compactMap({ $0 })
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
        var variables = type.variables.compactMap(makeArgument(from:))
        variables += type.functions.compactMap(makeReturnArgument(of:))
        let arguments = variables.joined(separator: ", ")

        guard !arguments.isEmpty else {
            return []
        }

        var bodyRows = type.variables.compactMap(makeAssigment(of:))
        bodyRows += type.functions.compactMap(makeReturnAssigment(of:))
        var result = [String]()
        result.append("\tinit(\(arguments)) {")
        result += bodyRows
        result.append("\t}")
        return result
    }

    private func makeArgument(from variable: VarDeclarationType) -> String? {
        if variable.type.isOptional {
            return nil
        } else {
            let typeString = TypeStringFactory.makeInitString(variable.type)
            return "\(variable.identifier): \(typeString)"
        }
    }

    private func makeAssigment(of variable: VarDeclarationType) -> String? {
        if variable.type.isOptional {
            return nil
        } else {
            return "\t\tself.\(variable.identifier) = \(variable.identifier)"
        }
    }

    private func makeReturnArgument(of function: FunctionDeclarationType) -> String? {
        guard let returnType = function.returnType, !returnType.isOptional else {
            return nil
        }
        let functionName = getName(from: function)
        let typeString = TypeStringFactory.makeInitString(returnType)
        return "\(functionName)Return: \(typeString)"
    }

    private func makeReturnAssigment(of function: FunctionDeclarationType) -> String? {
        guard let returnType = function.returnType, !returnType.isOptional else {
            return nil
        }
        let functionName = getName(from: function)

        return "\t\tself.\(functionName)Return = \(functionName)Return"
    }

    private func generateVariables(_ variables: [VarDeclarationType]) -> [String] {
        var result = [String]()

        for variable in variables {
            let typeString = TypeStringFactory.makeSimpleString(variable.type)
            result.append("\tvar \(variable.identifier): \(typeString)")
        }

        return result
    }

    private func generateSpyVariables(for functions: [FunctionDeclarationType]) -> [String] {
        var result = [String]()

        for function in functions {
            if !function.arguments.isEmpty {
                result.append(generateStruct(for: function))
            }
        }

        for function in functions {
            result.append(generateFunctionVariables(function))
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
            let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
            result += "\n\tvar \(functionName)Return: \(returnTypeString)"
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
        let typeString = TypeStringFactory.makeSimpleString(argument.type)
        return "\t\tlet \(argument.name): \(typeString)\n"
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
        let typeString = TypeStringFactory.makeFunctionArgumentString(argument.type)
        return "\(labelString)\(argument.name): \(typeString)"
    }

    private func generateSpy(of function: FunctionDeclarationType) -> [String] {
        if function.arguments.isEmpty {
            return generateSpyWithoutArguments(of: function)
        } else {
            return generateSpyWithArguments(of: function)
        }
    }

    private func generateSpyWithoutArguments(of function: FunctionDeclarationType) -> [String] {
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

    private func generateSpyWithArguments(of function: FunctionDeclarationType) -> [String] {
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

    private func makeFunctionDefinition(of function: FunctionDeclarationType, body: [String]) -> [String] {
        var result = [String]()
        let argumentsString = function.arguments.map(generateArgument).joined(separator: ", ")
        var returnString = ""

        if function.isThrowing {
            returnString += "throws "
        }

        if let returnType = function.returnType {
            let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
            returnString += "-> \(returnTypeString) "
        }

        result.append("\tfunc \(function.name)(\(argumentsString)) \(returnString){")
        result += body.map({ "\t\t\($0)" })
        result.append("\t}")
        return result
    }

    private func makeStructName(from function: FunctionDeclarationType) -> String {
        return getName(from: function).capitalizingFirstLetter()
    }
}
