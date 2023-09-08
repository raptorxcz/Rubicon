//
//  CreateStubInteractor.swift
//  Generator
//
//  Created by Kryštof Matěj on 16/02/2019.
//  Copyright © 2019 Kryštof Matěj. All rights reserved.
//

public final class CreateStubInteractor: CreateMockInteractor {
    private let accessLevel: AccessLevel
    private var protocolType: ProtocolDeclaration?

    public init(accessLevel: AccessLevel) {
        self.accessLevel = accessLevel
    }

    public func generate(from protocolType: ProtocolDeclaration) -> String {
        self.protocolType = protocolType
        var result = [String]()
        result.append("\(accessLevel.makeClassString())final class \(protocolType.name)Stub: \(protocolType.name) {")
        result += generateBody(from: protocolType)
        result.append("}")

        var string = result.joined(separator: "\n")
        if !string.isEmpty {
            string.append("\n")
        }
        return string
    }

    private func generateBody(from protocolType: ProtocolDeclaration) -> [String] {
        var content = [String]()

        if let throwSampleError = makeThrowSampleError(for: protocolType) {
            content.append("")
            content.append(throwSampleError)
        }

        if !protocolType.variables.isEmpty {
            content.append("")
            content += generateVariables(protocolType.variables)
        }

        let stubVariables = generateStubVariables(for: protocolType.functions)
        if !stubVariables.isEmpty {
            content.append("")
            content += stubVariables
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

    private func generateFunctionsBody(for protocolType: ProtocolDeclaration) -> [String] {
        var rows = [[String]]()

        for function in protocolType.functions {
            rows.append(generateStub(of: function))
        }

        return rows.joined(separator: [""]).compactMap({ $0 })
    }

    private func makeThrowSampleError(for type: ProtocolDeclaration) -> String? {
        let isAnyFuncThrowing = type.functions.contains(where: { $0.isThrowing })

        if isAnyFuncThrowing {
            return """
            \t\(accessLevel.makeContentString())enum StubError: Error {
            \t\tcase stubError
            \t}
            \t\(accessLevel.makeContentString())typealias ThrowBlock = () throws -> Void
            """
        } else {
            return nil
        }
    }

    private func generateInit(for type: ProtocolDeclaration) -> [String] {
        var variables = type.variables.compactMap(makeArgument(from:))
        variables += type.functions.compactMap(makeReturnArgument(of:))
        let arguments = variables.joined(separator: ", ")

        guard !arguments.isEmpty || accessLevel == .public else {
            return []
        }

        var bodyRows = type.variables.compactMap(makeAssigment(of:))
        bodyRows += type.functions.compactMap(makeReturnAssigment(of:))
        var result = [String]()
        result.append("\t\(accessLevel.makeContentString())init(\(arguments)) {")
        result += bodyRows
        result.append("\t}")
        return result
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

    private func generateVariables(_ variables: [VarDeclaration]) -> [String] {
        var result = [String]()

        for variable in variables {
            let typeString = TypeStringFactory.makeSimpleString(variable.type)
            result.append("\t\(accessLevel.makeContentString())var \(variable.identifier): \(typeString)")
        }

        return result
    }

    private func generateStubVariables(for functions: [FunctionDeclaration]) -> [String] {
        var result = [String]()

        for function in functions {
            result += generateFunctionVariables(function)
        }

        return result
    }

    private func generateFunctionVariables(_ function: FunctionDeclaration) -> [String] {
        let functionName = getName(from: function)

        var results = [String]()

        if function.isThrowing {
            results.append("\t\(accessLevel.makeContentString())var \(functionName)ThrowBlock: ThrowBlock?")
        }

        if let returnType = function.returnType {
            let returnTypeString = TypeStringFactory.makeSimpleString(returnType)
            results.append("\t\(accessLevel.makeContentString())var \(functionName)Return: \(returnTypeString)")
        }

        return results
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

    private func generateStub(of function: FunctionDeclaration) -> [String] {
        let functionName = getName(from: function)
        var functionBody = [String]()

        if function.isThrowing {
            functionBody.append("try \(functionName)ThrowBlock?()")
        }

        if function.returnType != nil {
            functionBody.append("return \(functionName)Return")
        }

        return makeFunctionDefinition(of: function, body: functionBody)
    }

    private func makeFunctionDefinition(of function: FunctionDeclaration, body: [String]) -> [String] {
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
        result += body.map({ "\t\t\($0)" })
        result.append("\t}")
        return result
    }
}
