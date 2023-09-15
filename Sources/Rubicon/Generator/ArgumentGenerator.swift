protocol ArgumentGenerator {
    func makeCode(from declaration: ArgumentDeclaration) -> String
}

final class ArgumentGeneratorImpl: ArgumentGenerator {
    private let typeGenerator: TypeGenerator

    init(typeGenerator: TypeGenerator) {
        self.typeGenerator = typeGenerator
    }

    func makeCode(from declaration: ArgumentDeclaration) -> String {
        if let label = declaration.label {
            return "\(label) \(declaration.name): \(typeGenerator.makeArgumentCode(from: declaration.type))"
        } else {
            return "\(declaration.name): \(typeGenerator.makeArgumentCode(from: declaration.type))"
        }
    }
}
