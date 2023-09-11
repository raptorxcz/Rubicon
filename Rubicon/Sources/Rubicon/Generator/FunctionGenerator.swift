protocol FunctionGenerator {
    func makeCode(from declaration: FunctionDeclaration, content: String) -> String
}

final class FunctionGeneratorImpl: FunctionGenerator {
    private let accessLevelGenerator: AccessLevelGenerator
    private let typeGenerator: TypeGenerator
    private let argumentGenerator: ArgumentGenerator

    init(
        accessLevelGenerator: AccessLevelGenerator,
        typeGenerator: TypeGenerator,
        argumentGenerator: ArgumentGenerator
    ) {
        self.accessLevelGenerator = accessLevelGenerator
        self.typeGenerator = typeGenerator
        self.argumentGenerator = argumentGenerator
    }

    func makeCode(from declaration: FunctionDeclaration, content: String) -> String {
        let returnString = makeReturn(from: declaration)
        let arguments = declaration.arguments.map(argumentGenerator.makeCode(from:)).joined(separator: ", ")
        return """
        \t\(accessLevelGenerator.makeContentAccessLevel())func \(declaration.name)(\(arguments)) \(returnString){
        \(content)
        \t}
        """
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
