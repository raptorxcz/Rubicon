public struct SpyConfiguration {
    public let accessLevel: AccessLevel
    public let indentStep: String
    public let isInitWithOptionalsEnabled: Bool

    public init(
        accessLevel: AccessLevel,
        indentStep: String,
        isInitWithOptionalsEnabled: Bool
    ) {
        self.accessLevel = accessLevel
        self.indentStep = indentStep
        self.isInitWithOptionalsEnabled = isInitWithOptionalsEnabled
    }
}

public struct StubConfiguration {
    public let accessLevel: AccessLevel
    public let indentStep: String
    public let nameSuffix: String
    public let isInitWithOptionalsEnabled: Bool

    public init(
        accessLevel: AccessLevel,
        indentStep: String,
        nameSuffix: String = "Stub",
        isInitWithOptionalsEnabled: Bool
    ) {
        self.accessLevel = accessLevel
        self.indentStep = indentStep
        self.nameSuffix = nameSuffix
        self.isInitWithOptionalsEnabled = isInitWithOptionalsEnabled
    }
}

public struct StructStubConfiguration {
    public let accessLevel: AccessLevel
    public let indentStep: String
    public let functionName: String
    public let defaultValue: String
    public let customDefaultValues: [String: String]

    public init(
        accessLevel: AccessLevel,
        indentStep: String,
        functionName: String,
        defaultValue: String,
        customDefaultValues: [String : String]
    ) {
        self.accessLevel = accessLevel
        self.indentStep = indentStep
        self.functionName = functionName
        self.defaultValue = defaultValue
        self.customDefaultValues = customDefaultValues
    }
}

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
        let structGenerator: StructGenerator
        let typeGenerator: TypeGenerator
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

    public func makeStub(code: String, configuration: StubConfiguration) -> [String] {
        let parser = makeParser()
        let generator = makeStubGenerator(
            accessLevel: configuration.accessLevel,
            indentStep: configuration.indentStep
        )
        do {
            let protocols = try parser.parse(text: code)
            return protocols.map {
                generator.generate(
                    from: $0,
                    nameSuffix: configuration.nameSuffix,
                    isInitWithOptionalsEnabled: configuration.isInitWithOptionalsEnabled
                )
            }
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

    public func makeSpy(code: String, configuration: SpyConfiguration) -> [String] {
        let parser = makeParser()
        let generator = makeSpyGenerator(
            accessLevel: configuration.accessLevel,
            indentStep: configuration.indentStep
        )
        do {
            let protocols = try parser.parse(text: code)
            return protocols.map{
                generator.generate(
                    from: $0,
                    isInitWithOptionalsEnabled: configuration.isInitWithOptionalsEnabled
                )
            }
        } catch {
            return []
        }
    }

    private func makeSpyGenerator(accessLevel: AccessLevel, indentStep: String) -> SpyGenerator {
        let dependencies = makeDependencies(for: accessLevel, indentStep: indentStep)
        return SpyGenerator(
            protocolGenerator: dependencies.protocolGenerator,
            variableGenerator: dependencies.variableGenerator,
            functionGenerator: dependencies.functionGenerator,
            functionNameGenerator: dependencies.functionNameGenerator,
            initGenerator: dependencies.initGenerator,
            structGenerator: dependencies.structGenerator,
            accessLevelGenerator: dependencies.accessLevelGenerator
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
        let structGenerator = StructGeneratorImpl(
            accessLevelGenerator: accessLevelGenerator,
            variableGenerator: variableGenerator,
            indentationGenerator: indentationGenerator
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
            initGenerator: initGenerator,
            structGenerator: structGenerator,
            typeGenerator: typeGenerator
        )
    }

    private func makeParser() -> ProtocolParser {

        let argumentDeclarationParser = ArgumentDeclarationParserImpl(
            typeDeclarationParser: makeTypeParser()
        )
        let functionParser = FunctionDeclarationParserImpl(
            typeDeclarationParser: makeTypeParser(),
            argumentDeclarationParser: argumentDeclarationParser
        )
        return ProtocolParserImpl(
            functionParser: functionParser,
            varParser: makeVarParser()
        )
    }

    public func updateTearDown(text: String, spacing: Int) throws -> String {
        let parser = NilableVariablesParserImpl()
        let tearDownInteractor = TearDownInteractor(nilableVariablesParser: parser)
        return try tearDownInteractor.execute(text: text, spacing: spacing)
    }

    public func makeStructStub(code: String, configuration: StructStubConfiguration) -> [String] {
        let parser = makeStuctParser()
        let structStubGenerator = makeStructStubGenerator(for: configuration)

        do {
            let structDeclarations = try parser.parse(text: code)
            return structDeclarations.map{ structStubGenerator.generate(from: $0, functionName: configuration.functionName) }
        } catch {
            return []
        }
    }

    public func makeStuctParser() -> StructParser {
        return StructParserImpl(
            varParser: makeVarParser()
        )
    }

    private func makeVarParser() -> VarDeclarationParser {
        return VarDeclarationParserImpl(
            typeDeclarationParser: makeTypeParser()
        )
    }

    private func makeTypeParser() -> TypeDeclarationParser {
        return TypeDeclarationParserImpl()
    }

    public func makeStructStubGenerator(for configuration: StructStubConfiguration) -> StructStubGenerator {
        let dependencies = makeDependencies(
            for: configuration.accessLevel,
            indentStep: configuration.indentStep
        )
        return StructStubGeneratorImpl(
            extensionGenerator: ExtensionGeneratorImpl(
                accessLevelGenerator: dependencies.accessLevelGenerator,
                indentationGenerator: dependencies.indentationGenerator
            ),
            functionGenerator: FunctionGeneratorImpl(
                accessLevelGenerator: dependencies.accessLevelGenerator,
                typeGenerator: dependencies.typeGenerator,
                argumentGenerator: dependencies.argumentGenerator,
                indentationGenerator: dependencies.indentationGenerator
            ),
            indentationGenerator: dependencies.indentationGenerator,
            defaultValueGenerator: DefaultValueGeneratorImpl(
                unknownDefaultType: configuration.defaultValue,
                customDefaultTypes: configuration.customDefaultValues
            )
        )
    }

    public func makeEnumParser() -> EnumParser {
        return EnumParserImpl()
    }

    public func makeEnumGenerator(for configuration: StructStubConfiguration) -> EnumStubGenerator {
        let dependencies = makeDependencies(
            for: configuration.accessLevel,
            indentStep: configuration.indentStep
        )
        return EnumStubGeneratorImpl(
            extensionGenerator: ExtensionGeneratorImpl(
                accessLevelGenerator: dependencies.accessLevelGenerator,
                indentationGenerator: dependencies.indentationGenerator
            ),
            functionGenerator: FunctionGeneratorImpl(
                accessLevelGenerator: dependencies.accessLevelGenerator,
                typeGenerator: dependencies.typeGenerator,
                argumentGenerator: dependencies.argumentGenerator,
                indentationGenerator: dependencies.indentationGenerator
            ),
            indentationGenerator: dependencies.indentationGenerator,
            defaultValueGenerator: DefaultValueGeneratorImpl(
                unknownDefaultType: configuration.defaultValue,
                customDefaultTypes: configuration.customDefaultValues
            )
        )
    }
}
