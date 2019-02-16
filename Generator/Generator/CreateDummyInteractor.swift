//
//  CreateDummyInteractor.swift
//  Generator
//
//  Created by Kryštof Matěj on 15/02/2019.
//  Copyright © 2019 Kryštof Matěj. All rights reserved.
//

public protocol CreateMockInteractor {
    func generate(from protocolType: ProtocolType) -> String
}

public final class CreateDummyInteractor: CreateMockInteractor {

    private let visibility: String?
    private var protocolType: ProtocolType?

    public init(visibility: String? = nil) {
        self.visibility = visibility
    }

    public func generate(from protocolType: ProtocolType) -> String {
        self.protocolType = protocolType
        var result = [String]()
        result.append("\(makeVisibilityString())class \(protocolType.name)Dummy: \(protocolType.name) {")
        result += generateBody(from: protocolType)
        result.append("}")

        var string = result.joined(separator: "\n")
        if !string.isEmpty {
            string.append("\n")
        }
        return string
    }

    private func makeVisibilityString() -> String {
        if let visibility = visibility {
            return "\(visibility) "
        } else {
            return ""
        }
    }

    private func generateBody(from protocolType: ProtocolType) -> [String] {
        var content = [String]()

        if !protocolType.variables.isEmpty {
            content.append("")
            content += generateVariables(protocolType.variables)
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
            rows.append(generateDummy(of: function))
        }

        return rows.joined(separator: [""]).compactMap({ $0 })
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

            if variable.isConstant {
                result += [
                    "\tvar \(variable.identifier): \(typeString) {",
                    "\t\tfatalError()",
                    "\t}",
                ]
            } else {
                result += [
                    "\tvar \(variable.identifier): \(typeString) {",
                    "\t\tget {",
                    "\t\t\tfatalError()",
                    "\t\t}",
                    "\t\tset {",
                    "\t\t\tfatalError()",
                    "\t\t}",
                    "\t}",
                ]
            }
        }

        return result
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

    private func generateDummy(of function: FunctionDeclarationType) -> [String] {
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
        result.append("\t\tfatalError()")
        result.append("\t}")
        return result
    }
}
