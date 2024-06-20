public struct StructDeclaration: Equatable {
    let name: String
    let variables: [VarDeclaration]
    public let notes: [String]
    public let accessLevel: AccessLevel
}
