public final class Rubicon {
    public init() {}

    struct Dependencies {
        let protocolGenerator: ProtocolGenerator
        let variableGenerator: VariableGenerator
        let functionGenerator: FunctionGenerator
        let accessLevel: AccessLevel
        let accessLevelGenerator: AccessLevelGenerator
        let argumentGenerator: ArgumentGenerator
        let functionNameGenerator: FunctionNameGenerator
        let indentationGenerator: IndentationGenerator
        let initGenerator: InitGenerator
    }

    public func makeDummy(code: String, accessLevel: AccessLevel, indentStep: String) -> [String] {
        let parser = makeParser()
        let generator = makeDummyGenerator(accessLevel: accessLevel, indentStep: indentStep)
        do {
            let protocols = try parser.parse(text: code)
            return protocols.map(generator.generate(from:))
        } catch {
            return []
        }
    }

    private func makeDummyGenerator(accessLevel: AccessLevel, indentStep: String) -> DummyGenerator {
        let dependencies = makeDependencies(for: accessLevel, indentStep: indentStep)
        return DummyGenerator(
            protocolGenerator: dependencies.protocolGenerator,
            variableGenerator: dependencies.variableGenerator,
            functionGenerator: dependencies.functionGenerator,
            initGenerator: dependencies.initGenerator
        )
    }

    public func makeStub(code: String, accessLevel: AccessLevel, indentStep: String) -> [String] {
        let parser = makeParser()
        let generator = makeStubGenerator(accessLevel: accessLevel, indentStep: indentStep)
        do {
            let protocols = try parser.parse(text: code)
            return protocols.map(generator.generate(from:))
        } catch {
            return []
        }
    }

    private func makeStubGenerator(accessLevel: AccessLevel, indentStep: String) -> StubGenerator {
        let dependencies = makeDependencies(for: accessLevel, indentStep: indentStep)
        return StubGenerator(
            protocolGenerator: dependencies.protocolGenerator,
            variableGenerator: dependencies.variableGenerator,
            functionGenerator: dependencies.functionGenerator,
            functionNameGenerator: dependencies.functionNameGenerator,
            initGenerator: dependencies.initGenerator
        )
    }


    private func makeDependencies(for accessLevel: AccessLevel, indentStep: String) -> Dependencies {
        let indentationGenerator = IndentationGeneratorImpl(indentStep: indentStep)
        let accessLevelGenerator = AccessLevelGeneratorImpl(
            accessLevel: accessLevel
        )
        let protocolGenerator = ProtocolGeneratorImpl(
            accessLevelGenerator: accessLevelGenerator,
            indentationGenerator: indentationGenerator
        )
        let typeGenerator = TypeGeneratorImpl()
        let variableGenerator = VariableGeneratorImpl(
            typeGenerator: typeGenerator,
            accessLevelGenerator: accessLevelGenerator,
            indentationGenerator: indentationGenerator
        )
        let argumentGenerator = ArgumentGeneratorImpl(typeGenerator: typeGenerator)
        let functionGenerator = FunctionGeneratorImpl(
            accessLevelGenerator: accessLevelGenerator,
            typeGenerator: typeGenerator,
            argumentGenerator: argumentGenerator,
            indentationGenerator: indentationGenerator
        )
        let functionNameGenerator = FunctionNameGeneratorImpl()
        let initGenerator = InitGeneratorImpl(
            accessLevel: accessLevel,
            accessLevelGenerator: accessLevelGenerator,
            indentationGenerator: indentationGenerator,
            argumentGenerator: argumentGenerator
        )

        return Dependencies(
            protocolGenerator: protocolGenerator,
            variableGenerator: variableGenerator,
            functionGenerator: functionGenerator,
            accessLevel: accessLevel,
            accessLevelGenerator: accessLevelGenerator,
            argumentGenerator: argumentGenerator,
            functionNameGenerator: functionNameGenerator,
            indentationGenerator: indentationGenerator,
            initGenerator: initGenerator
        )
    }

    private func makeParser() -> ProtocolParser {
        let typeDeclarationParser = TypeDeclarationParserImpl()
        let argumentDeclarationParser = ArgumentDeclarationParserImpl(
            typeDeclarationParser: typeDeclarationParser
        )
        let functionParser = FunctionDeclarationParserImpl(
            typeDeclarationParser: typeDeclarationParser,
            argumentDeclarationParser: argumentDeclarationParser
        )
        let varParser = VarDeclarationParserImpl(
            typeDeclarationParser: typeDeclarationParser
        )
        return ProtocolParserImpl(
            functionParser: functionParser,
            varParser: varParser
        )
    }

}
