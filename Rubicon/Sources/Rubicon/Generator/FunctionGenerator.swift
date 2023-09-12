protocol FunctionGenerator {
    func makeCode(from declaration: FunctionDeclaration, content: [String]) -> [String]
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

    func makeCode(from declaration: FunctionDeclaration, content: [String]) -> [String] {
        let returnString = makeReturn(from: declaration)
        let arguments = declaration.arguments.map(argumentGenerator.makeCode(from:)).joined(separator: ", ")
        let content = content.map(indentationGenerator.indenting)
        return [
            "\(accessLevelGenerator.makeContentAccessLevel())func \(declaration.name)(\(arguments)) \(returnString){",
        ] + content + [
            "}",
        ]
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
