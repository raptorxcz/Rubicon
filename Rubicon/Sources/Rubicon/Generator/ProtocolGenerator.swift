protocol ProtocolGenerator {
    func makeProtocol(from declaration: ProtocolDeclaration, stub: String, content: [String]) -> [String]
}

final class ProtocolGeneratorImpl: ProtocolGenerator {
    private let accessLevelGenerator: AccessLevelGenerator
    private let indentationGenerator: IndentationGenerator

    init(
        accessLevelGenerator: AccessLevelGenerator,
        indentationGenerator: IndentationGenerator
    ) {
        self.accessLevelGenerator = accessLevelGenerator
        self.indentationGenerator = indentationGenerator
    }

    func makeProtocol(from declaration: ProtocolDeclaration, stub: String, content: [String]) -> [String] {
        let content = content.map(indentationGenerator.indenting)
        return [
        "\(accessLevelGenerator.makeClassAccessLevel())final class \(declaration.name)\(stub): \(declaration.name) {"
        ] + content + [
        "}",
        ]
    }
}
