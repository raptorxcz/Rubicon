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
        let parentClause = makeParentClause(from: declaration, stub: stub)
        let header = declaration.name + stub + parentClause + declaration.name
        return [
        "\(accessLevelGenerator.makeClassAccessLevel())final class \(header) {"
        ] + content + [
        "}",
        ]
    }

    private func makeParentClause(from declaration: ProtocolDeclaration, stub: String) -> String {
        let normalizedParents = declaration.parents.filter { $0 != "AnyObject" }
        
        if let parent = normalizedParents.first, normalizedParents.count == 1 {
            return ": \(parent)\(stub), "
        } else {
            return ": "
        }
    }
}
