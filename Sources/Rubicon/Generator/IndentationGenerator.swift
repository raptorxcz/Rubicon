protocol IndentationGenerator {
    func indenting(_ string: String) -> String
}

final class IndentationGeneratorImpl: IndentationGenerator {
    private let indentStep: String

    init(indentStep: String) {
        self.indentStep = indentStep
    }

    func indenting(_ string: String) -> String {
        if string.isEmpty {
            return string
        } else {
            return indentStep + string
        }
    }
}
