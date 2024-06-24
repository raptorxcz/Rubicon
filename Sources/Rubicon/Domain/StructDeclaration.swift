public struct StructDeclaration: Equatable {
    public let name: String
    let variables: [VarDeclaration]
    public let notes: [String]
    public let accessLevel: AccessLevel
}
