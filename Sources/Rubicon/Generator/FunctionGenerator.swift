protocol FunctionGenerator {
    func makeCode(from declaration: FunctionDeclaration, content: [String], isEachArgumentOnNewLineEnabled: Bool) -> [String]
}

final class FunctionGeneratorImpl: FunctionGenerator {
    private let accessLevelGenerator: AccessLevelGenerator
    private let typeGenerator: TypeGenerator
    private let argumentGenerator: ArgumentGenerator
    private let indentationGenerator: IndentationGenerator

    init(
        accessLevelGenerator: AccessLevelGenerator,
        typeGenerator: TypeGenerator,
        argumentGenerator: ArgumentGenerator,
        indentationGenerator: IndentationGenerator
    ) {
        self.accessLevelGenerator = accessLevelGenerator
        self.typeGenerator = typeGenerator
        self.argumentGenerator = argumentGenerator
        self.indentationGenerator = indentationGenerator
    }

    func makeCode(from declaration: FunctionDeclaration, content: [String], isEachArgumentOnNewLineEnabled: Bool) -> [String] {
        let content = content.map(indentationGenerator.indenting)
        let arguments = makeArguments(from: declaration)
        let header = makeHeader(from: declaration, arguments: arguments, isEachArgumentOnNewLineEnabled: isEachArgumentOnNewLineEnabled)
        let normalizedHeader = isEachArgumentOnNewLineEnabled ? header : [header.joined()]
        return normalizedHeader + content + [
            "}",
        ]
    }

    private func makeArguments(from declaration: FunctionDeclaration) -> [String] {
        let arguments = declaration.arguments.map(argumentGenerator.makeCode(from:))
        var normalizedArguments = [String]()

        for (index, argument) in arguments.enumerated() {
            normalizedArguments.append(index == arguments.endIndex - 1 ? argument : argument + ",")
        }
        
        return normalizedArguments
    }

    private func makeHeader(from declaration: FunctionDeclaration, arguments: [String], isEachArgumentOnNewLineEnabled: Bool) -> [String] {
        let staticString = declaration.isStatic ? "static " : ""
        let returnString = makeReturn(from: declaration)
        let prefix = "\(accessLevelGenerator.makeContentAccessLevel())\(staticString)func \(declaration.name)("
        let suffix = ") \(returnString){"

        if isEachArgumentOnNewLineEnabled {
            return [prefix] + arguments.map(indentationGenerator.indenting) + [suffix]
        } else {
            return [[
                prefix,
                arguments.joined(separator: " "),
                suffix
            ].joined()]
        }
    }

    private func makeReturn(from declaration: FunctionDeclaration) -> String {
        var result = ""

        if declaration.isAsync {
            result += "async "
        }

        if declaration.isThrowing {
            result += "throws "
        }

        if let returnType = declaration.returnType {
            result += "-> \(typeGenerator.makeVariableCode(from: returnType)) "
        }

        return result
    }
}
