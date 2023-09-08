//
//  CreateSpyInteractor.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//
//
//public class CreateSpyInteractor: CreateMockInteractor {
//    private let accessLevel: AccessLevel
//    private var protocolType: ProtocolDeclaration?
//
//    public init(accessLevel: AccessLevel) {
//        self.accessLevel = accessLevel
//    }
//
//    public func generate(from protocolType: ProtocolDeclaration) -> String {
//        self.protocolType = protocolType
//        var result = [String]()
//        result.append("\(accessLevel.makeClassString())final class \(protocolType.name)Spy: \(protocolType.name) {")
//        result += generateBody(from: protocolType)
//        result.append("}")
//
//        var string = result.joined(separator: "\n")
//        if !string.isEmpty {
//            string.append("\n")
//        }
//        return string
//    }
//
//    private func generateBody(from protocolType: ProtocolDeclaration) -> [String] {
//        var content = [String]()
//
//        if let throwSampleError = makeThrowSampleError(for: protocolType) {
//            content.append("")
//            content.append(throwSampleError)
//        }
//
//        if !protocolType.variables.isEmpty {
//            content.append("")
//            content += generateVariables(protocolType.variables)
//        }
//
//        if !protocolType.functions.isEmpty {
//            content.append("")
//            content += generateSpyVariables(for: protocolType.functions)
//        }
//
//        let initRows = generateInit(for: protocolType)
//
//        if !initRows.isEmpty {
//            content.append("")
//            content += initRows
//        }
//
//        let body = generateFunctionsBody(for: protocolType)
//        if !body.isEmpty {
//            content.append("")
//            content += body
//        }
//
//        return content
//    }
//
//    private func generateFunctionsBody(for protocolType: ProtocolDeclaration) -> [String] {
//        var rows = [[String]]()
//
//        for function in protocolType.functions {
//            rows.append(generateSpy(of: function))
//        }
//
//        return rows.joined(separator: [""]).compactMap({ $0 })
//    }
//
//    private func makeThrowSampleError(for type: ProtocolDeclaration) -> String? {
//        let isAnyFuncThrowing = type.functions.contains(where: { $0.isThrowing })
//
//        if isAnyFuncThrowing {
//            return """
//            \t\(accessLevel.makeContentString())enum SpyError: Error {
//            \t\tcase spyError
//            \t}
//            \t\(accessLevel.makeContentString())typealias ThrowBlock = () throws -> Void
//            """
//        } else {
//            return nil
//        }
//    }
//
//    private func generateInit(for type: ProtocolDeclaration) -> [String] {
//        var variables = type.variables.compactMap(makeArgument(from:))
//        variables += type.functions.compactMap(makeReturnArgument(of:))
//        let arguments = variables.joined(separator: ", ")
//
//        guard !arguments.isEmpty || accessLevel == .public else {
//            return []
//        }
//
//        var bodyRows = type.variables.compactMap(makeAssigment(of:))
//        bodyRows += type.functions.compactMap(makeReturnAssigment(of:))
//        var result = [String]()
//        result.append("\t\(accessLevel.makeContentString())init(\(arguments)) {")
//        result += bodyRows
//        result.append("\t}")
//        return result
//    }
//
//    private func makeArgument(from variable: VarDeclaration) -> String? {
//        if variable.type.isOptional {
//            return nil
//        } else {
//            let typeString = TypeStringFactory.makeInitString(variable.type)
//            return "\(variable.identifier): \(typeString)"
//        }
//    }
//
//    private func makeAssigment(of variable: VarDeclaration) -> String? {
//        if variable.type.isOptional {
//            return nil
//        } else {
//            return "\t\tself.\(variable.identifier) = \(variable.identifier)"
//        }
//    }
//
//    private func makeReturnArgument(of function: FunctionDeclaration) -> String? {
//        guard let returnType = function.returnType, !returnType.isOptional else {
//            return nil
//        }
//        let functionName = getName(from: function)
//        let typeString = TypeStringFactory.makeInitString(returnType)
//        return "\(functionName)Return: \(typeString)"
//    }
//
//    private func makeReturnAssigment(of function: FunctionDeclaration) -> String? {
//        guard let returnType = function.returnType, !returnType.isOptional else {
//            return nil
//        }
//        let functionName = getName(from: function)
//
//        return "\t\tself.\(functionName)Return = \(functionName)Return"
//    }
//
//    private func generateVariables(_ variables: [VarDeclaration]) -> [String] {
//        var result = [String]()
//
//        for variable in variables {
//            let typeString = TypeStringFactory.makeSimpleString(variable.type)
//            result.append("\t\(accessLevel.makeContentString())var \(variable.identifier): \(typeString)")
//        }
//
//        return result
//    }
//
//    private func generateSpyVariables(for functions: [FunctionDeclaration]) -> [String] {
//        var result = [String]()
//
//        for function in functions {
//            if !function.arguments.isEmpty {
//                result.append(generateStruct(for: function))
//            }
//        }
//
//        for function in functions {
//            result.append(generateFunctionVariables(function))
//        }
//
//        return result
//    }
//
//    private func generateFunctionVariables(_ function: FunctionDeclaration) -> String {
//        let functionName = getName(from: function)
//
//        var result = ""
//
//        if function.arguments.isEmpty {
//            result += "\t\(accessLevel.makeContentString())var \(functionName)Count = 0"
//        } else {
//            result += generateCallStackVariable(for: function)
//        }
//
//        if function.isThrowing {
//            result += "\n\t\(accessLevel.makeContentString())var \(functionName)ThrowBlock: ThrowBlock?"
//        }
//
//        if let returnType = function.returnType {
//            let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
//            result += "\n\t\(accessLevel.makeContentString())var \(functionName)Return: \(returnTypeString)"
//        }
//
//        return result
//    }
//
//    private func generateCallStackVariable(for function: FunctionDeclaration) -> String {
//        let functionName = getName(from: function)
//        let structName = makeStructName(from: function)
//        return "\t\(accessLevel.makeContentString())var \(functionName) = [\(structName)]()"
//    }
//
//    private func generateStruct(for function: FunctionDeclaration) -> String {
//        let structName = makeStructName(from: function)
//
//        var result = ""
//        result += "\t\(accessLevel.makeContentString())struct \(structName) {\n"
//        result += function.arguments.map(makeRow(for:)).joined()
//        result += "\t}\n"
//        return result
//    }
//
//    private func makeRow(for argument: ArgumentDeclaration) -> String {
//        let typeString = TypeStringFactory.makeSimpleString(argument.type)
//        return "\t\t\(accessLevel.makeContentString())let \(argument.name): \(typeString)\n"
//    }
//
//    private func getName(from function: FunctionDeclaration) -> String {
//        let argumentsTitles = function.arguments.map(getArgumentName(from:)).joined()
//        let arguments = isFunctionNameUnique(function) ? argumentsTitles : ""
//
//        return "\(function.name)\(arguments)"
//    }
//
//    private func getArgumentName(from type: ArgumentDeclaration) -> String {
//        if let label = type.label, label != "_" {
//            return label.capitalizingFirstLetter()
//        } else {
//            return type.name.capitalizingFirstLetter()
//        }
//    }
//
//    private func isFunctionNameUnique(_ function: FunctionDeclaration) -> Bool {
//        guard let protocolType = protocolType else {
//            return false
//        }
//
//        var matchCount = 0
//
//        for fc in protocolType.functions {
//            if fc.name == function.name {
//                matchCount += 1
//            }
//        }
//
//        return matchCount > 1
//    }
//
//    private func generateArgument(_ argument: ArgumentDeclaration) -> String {
//        let labelString: String
//
//        if let label = argument.label {
//            labelString = "\(label) "
//        } else {
//            labelString = ""
//        }
//        let typeString = TypeStringFactory.makeFunctionArgumentString(argument.type)
//        return "\(labelString)\(argument.name): \(typeString)"
//    }
//
//    private func generateSpy(of function: FunctionDeclaration) -> [String] {
//        if function.arguments.isEmpty {
//            return generateSpyWithoutArguments(of: function)
//        } else {
//            return generateSpyWithArguments(of: function)
//        }
//    }
//
//    private func generateSpyWithoutArguments(of function: FunctionDeclaration) -> [String] {
//        let functionName = getName(from: function)
//        var functionBody = [String]()
//
//        functionBody.append("\(functionName)Count += 1")
//
//        if function.isThrowing {
//            functionBody.append("try \(functionName)ThrowBlock?()")
//        }
//
//        if function.returnType != nil {
//            functionBody.append("return \(functionName)Return")
//        }
//
//        return makeFunctionDefinition(of: function, body: functionBody)
//    }
//
//    private func generateSpyWithArguments(of function: FunctionDeclaration) -> [String] {
//        let functionName = getName(from: function)
//        let structName = makeStructName(from: function)
//
//        var functionBody = [String]()
//        let argumentList = function.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", ")
//
//        functionBody.append("let item = \(structName)(\(argumentList))")
//        functionBody.append("\(functionName).append(item)")
//
//        if function.isThrowing {
//            functionBody.append("try \(functionName)ThrowBlock?()")
//        }
//
//        if function.returnType != nil {
//            functionBody.append("return \(functionName)Return")
//        }
//
//        return makeFunctionDefinition(of: function, body: functionBody)
//    }
//
//    private func makeFunctionDefinition(of function: FunctionDeclaration, body: [String]) -> [String] {
//        var result = [String]()
//        let argumentsString = function.arguments.map(generateArgument).joined(separator: ", ")
//        var returnString = ""
//
//        if function.isAsync {
//            returnString += "async "
//        }
//
//        if function.isThrowing {
//            returnString += "throws "
//        }
//
//        if let returnType = function.returnType {
//            let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
//            returnString += "-> \(returnTypeString) "
//        }
//
//        result.append("\t\(accessLevel.makeContentString())func \(function.name)(\(argumentsString)) \(returnString){")
//        result += body.map({ "\t\t\($0)" })
//        result.append("\t}")
//        return result
//    }
//
//    private func makeStructName(from function: FunctionDeclaration) -> String {
//        return getName(from: function).capitalizingFirstLetter()
//    }
//}
