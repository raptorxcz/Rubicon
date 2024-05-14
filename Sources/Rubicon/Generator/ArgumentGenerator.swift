protocol ArgumentGenerator {
    func makeCode(from declaration: ArgumentDeclaration) -> String
}

final class ArgumentGeneratorImpl: ArgumentGenerator {
    private let typeGenerator: TypeGenerator

    init(typeGenerator: TypeGenerator) {
        self.typeGenerator = typeGenerator
    }

    func makeCode(from declaration: ArgumentDeclaration) -> String {
        let label = makeLabel(from: declaration)
        let defaultValue = makeDefaultValue(from: declaration)
        return "\(label)\(declaration.name): \(typeGenerator.makeArgumentCode(from: declaration.type))\(defaultValue)"
    }

    private func makeLabel(from declaration: ArgumentDeclaration) -> String {
        if let label = declaration.label {
            return "\(label) "
        } else {
            return ""
        }
    }

    private func makeDefaultValue(from declaration: ArgumentDeclaration) -> String {
        if let defaultValue = declaration.defaultValue {
            return " = \(defaultValue)"
        } else {
            return ""
        }
    }
}
