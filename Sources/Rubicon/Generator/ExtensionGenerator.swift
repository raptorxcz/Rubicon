protocol ExtensionGenerator {
    func make(name: String, content: [String]) -> [String]
}

final class ExtensionGeneratorImpl: ExtensionGenerator {
    private let accessLevelGenerator: AccessLevelGenerator
    private let indentationGenerator: IndentationGenerator

    init(
        accessLevelGenerator: AccessLevelGenerator,
        indentationGenerator: IndentationGenerator
    ) {
        self.accessLevelGenerator = accessLevelGenerator
        self.indentationGenerator = indentationGenerator
    }

    func make(name: String, content: [String]) -> [String] {
        let content = content.map(indentationGenerator.indenting)
        return [
        "\(accessLevelGenerator.makeClassAccessLevel())extension \(name) {"
        ] + content + [
        "}",
        ]
    }
}
