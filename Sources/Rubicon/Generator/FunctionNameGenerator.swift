protocol FunctionNameGenerator {
    func makeUniqueName(for function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> String
    func makeStructUniqueName(for function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> String
}

final class FunctionNameGeneratorImpl: FunctionNameGenerator {
    func makeUniqueName(for function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> String {
        if isFunctionNameUnique(function, in: functions) {
            return function.name
        } else {
            return makeLongName(for: function)
        }
    }

    private func makeLongName(for function: FunctionDeclaration) -> String {
        return ([stringReplacingEscapingCharacters(in: function.name)] + function.arguments.map(makeLongArgument(for:))).joined()
    }

    private func makeLongArgument(for argument: ArgumentDeclaration) -> String {
        return [argument.label, argument.name].compactMap({ $0 }).map(normalize(string:)).joined()
    }

    private func normalize(string: String) -> String {
        if string == "_" {
            return ""
        } else {
            return makeFirstLetterCapitalized(in: string)
        }
    }

    private func makeFirstLetterCapitalized(in string: String) -> String {
        let functionNameWithoutEscapingCharacters = stringReplacingEscapingCharacters(in: string)
        let first = String(functionNameWithoutEscapingCharacters.prefix(1)).capitalized
        let other = String(functionNameWithoutEscapingCharacters.dropFirst())
        return first + other
    }

    private func stringReplacingEscapingCharacters(in string: String) -> String {
        string.replacingOccurrences(of: "`", with: "")
    }

    private func isFunctionNameUnique(_ function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> Bool {
        return !functions.contains(where:  { $0.name == function.name && $0 != function })
    }

    func makeStructUniqueName(for function: FunctionDeclaration, in functions: [FunctionDeclaration]) -> String {
        return makeFirstLetterCapitalized(in: makeUniqueName(for: function, in: functions))
    }
}
