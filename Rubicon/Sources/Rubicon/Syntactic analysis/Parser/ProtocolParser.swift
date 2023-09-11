import SwiftParser
import SwiftSyntax

protocol ProtocolParser {
    func parse(text: String) throws -> [ProtocolDeclaration]
}

final class ProtocolParserImpl: ProtocolParser {
    private let functionParser: FunctionDeclarationParser
    private let varParser: VarDeclarationParser

    init(
        functionParser: FunctionDeclarationParser,
        varParser: VarDeclarationParser
    ) {
        self.functionParser = functionParser
        self.varParser = varParser
    }

    func parse(text: String) throws -> [ProtocolDeclaration] {
        let text = SwiftParser.Parser.parse(source: text)
        let visitor = ProtocolVisitor(
            functionParser: functionParser,
            varParser: varParser
        )
        return visitor.execute(node: text)
    }
}

private class ProtocolVisitor: SyntaxVisitor {
    private let functionParser: FunctionDeclarationParser
    private let varParser: VarDeclarationParser
    private var result = [ProtocolDeclaration]()

    public init(
        functionParser: FunctionDeclarationParser,
        varParser: VarDeclarationParser
    ) {
        self.functionParser = functionParser
        self.varParser = varParser
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [ProtocolDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let functionsVisitor = FunctionsVisitor(functionParser: functionParser)
        let varsVisitor = VariablesVisitor(varParser: varParser)

        result.append(
            ProtocolDeclaration(
                name: node.name.text,
                parents: [],
                variables: varsVisitor.execute(node: node),
                functions: functionsVisitor.execute(node: node)
            )
        )
        return .visitChildren
    }
}

private class FunctionsVisitor: SyntaxVisitor {
    private let functionParser: FunctionDeclarationParser
    private var result = [FunctionDeclaration]()

    public init(functionParser: FunctionDeclarationParser) {
        self.functionParser = functionParser
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [FunctionDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let declaration = functionParser.parse(node: node)
        result.append(declaration)
        return .visitChildren
    }
}


private class VariablesVisitor: SyntaxVisitor {
    private let varParser: VarDeclarationParser
    private var result = [VarDeclaration]()

    public init(varParser: VarDeclarationParser) {
        self.varParser = varParser
        super.init(viewMode: .sourceAccurate)
    }

    func execute(node: some SyntaxProtocol) -> [VarDeclaration] {
        walk(node)
        return result
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        do {
            let declaration = try varParser.parse(node: node)
            result.append(declaration)
        } catch {}
        return .visitChildren
    }
}
