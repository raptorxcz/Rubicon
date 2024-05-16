import Foundation

protocol DefaultValueGenerator {
    func makeDefaultValue(for varDeclaration: VarDeclaration) -> String
}

final class DefaultValueGeneratorImpl: DefaultValueGenerator {
    private let unknownDefaultType: String
    private let customDefaultTypes: [String: String]

    init(unknownDefaultType: String, customDefaultTypes: [String: String]) {
        self.unknownDefaultType = unknownDefaultType
        self.customDefaultTypes = customDefaultTypes
    }

    func makeDefaultValue(for varDeclaration: VarDeclaration) -> String {
        if let customValue = customDefaultTypes[varDeclaration.type.name] {
            return customValue
        }

        switch varDeclaration.type.composedType {
        case .plain:
            return makeDefaultValueByType(varDeclaration: varDeclaration)
        case .array:
            return "[]"
        case .dictionary:
            return "[:]"
        case .optional:
            return "nil"
        case .set:
            return "[]"
        }
    }

    private func makeDefaultValueByType(varDeclaration: VarDeclaration) -> String {
        switch varDeclaration.type.name {
        case "String":
            return "\"\(varDeclaration.identifier)\""
        case "Int":
            return "0"
        case "Bool":
            return "false"
        default:
            return unknownDefaultType
        }
    }
}
