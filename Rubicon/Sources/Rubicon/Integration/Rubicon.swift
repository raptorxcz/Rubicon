public final class Rubicon {
    public init() {}

    public func makeDummy(code: String, accessLevel: AccessLevel) -> [String] {
        let parser = makeParser()
        let dummyGenerator = makeDummyGenerator(accessLevel: accessLevel)
        do {
            let protocols = try parser.parse(text: code)
            return protocols.map(dummyGenerator.generate(from:))
        } catch {
            return []
        }
    }

    private func makeDummyGenerator(accessLevel: AccessLevel) -> DummyGenerator {
        let accessLevelGenerator = AccessLevelGeneratorImpl(
            accessLevel: accessLevel
        )
        let protocolGenerator = ProtocolGeneratorImpl(
            accessLevelGenerator: accessLevelGenerator
        )
        let typeGenerator = TypeGeneratorImpl()
        let variableGenerator = VariableGeneratorImpl(
            typeGenerator: typeGenerator,
            accessLevelGenerator: accessLevelGenerator
        )
        let argumentGenerator = ArgumentGeneratorImpl(typeGenerator: typeGenerator)
        let functionGenerator = FunctionGeneratorImpl(
            accessLevelGenerator: accessLevelGenerator,
            typeGenerator: typeGenerator,
            argumentGenerator: argumentGenerator
        )
        return DummyGenerator(
            protocolGenerator: protocolGenerator,
            variableGenerator: variableGenerator,
            functionGenerator: functionGenerator,
            accessLevel: accessLevel,
            accessLevelGenerator: accessLevelGenerator
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
