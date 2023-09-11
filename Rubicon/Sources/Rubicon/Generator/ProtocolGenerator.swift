protocol ProtocolGenerator {
    func makeProtocol(from declaration: ProtocolDeclaration, stub: String, content: String) -> String
}

final class ProtocolGeneratorImpl: ProtocolGenerator {
    private let accessLevelGenerator: AccessLevelGenerator

    init(accessLevelGenerator: AccessLevelGenerator) {
        self.accessLevelGenerator = accessLevelGenerator
    }

    func makeProtocol(from declaration: ProtocolDeclaration, stub: String, content: String) -> String {
        return """
        \(accessLevelGenerator.makeClassAccessLevel())final class \(declaration.name)Dummy: \(declaration.name) {
        \(content)
        }
        
        """
    }
}
