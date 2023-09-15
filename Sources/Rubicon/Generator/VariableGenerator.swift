protocol VariableGenerator {
    func makeStubCode(from declaration: VarDeclaration, getContent: [String], setContent: [String]) -> [String]
    func makeCode(from declaration: VarDeclaration) -> String
}

final class VariableGeneratorImpl: VariableGenerator {
    private let typeGenerator: TypeGenerator
    private let accessLevelGenerator: AccessLevelGenerator
    private let indentationGenerator: IndentationGenerator

    init(
        typeGenerator: TypeGenerator,
        accessLevelGenerator: AccessLevelGenerator,
        indentationGenerator: IndentationGenerator
    ) {
        self.typeGenerator = typeGenerator
        self.accessLevelGenerator = accessLevelGenerator
        self.indentationGenerator = indentationGenerator
    }

    func makeStubCode(from declaration: VarDeclaration, getContent: [String], setContent: [String]) -> [String] {
        let getContent = getContent.map(indentationGenerator.indenting).map(indentationGenerator.indenting)
        let setContent = setContent.map(indentationGenerator.indenting).map(indentationGenerator.indenting)
        if declaration.isConstant {
            return [
                "\(accessLevelGenerator.makeContentAccessLevel())var \(declaration.identifier): \(typeGenerator.makeVariableCode(from: declaration.type)) {",
                indentationGenerator.indenting("get {"),
            ] + getContent + [
                indentationGenerator.indenting("}"),
                "}",
            ]
        } else {
            return [
                "\(accessLevelGenerator.makeContentAccessLevel())var \(declaration.identifier): \(typeGenerator.makeVariableCode(from: declaration.type)) {",
                indentationGenerator.indenting("get {"),
            ] + getContent + [
                indentationGenerator.indenting("}"),
                indentationGenerator.indenting("set {"),
            ] + setContent + [
                indentationGenerator.indenting("}"),
                "}",
            ]
        }
    }

    func makeCode(from declaration: VarDeclaration) -> String {
        let binding = declaration.isConstant ? "let" : "var"
        return "\(accessLevelGenerator.makeContentAccessLevel())\(binding) \(declaration.identifier): \(typeGenerator.makeVariableCode(from: declaration.type))"
    }
}
