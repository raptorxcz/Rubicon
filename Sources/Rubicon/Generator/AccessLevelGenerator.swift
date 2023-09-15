protocol AccessLevelGenerator {
    func makeClassAccessLevel() -> String
    func makeContentAccessLevel() -> String
}

final class AccessLevelGeneratorImpl: AccessLevelGenerator {
    private let accessLevel: AccessLevel

    init(accessLevel: AccessLevel) {
        self.accessLevel = accessLevel
    }

    func makeClassAccessLevel() -> String {
        switch accessLevel {
        case .public:
            return "public "
        case .internal:
            return ""
        case .private:
            return "private "
        }
    }

    func makeContentAccessLevel() -> String {
        switch accessLevel {
        case .public:
            return "public "
        case .internal:
            return ""
        case .private:
            return ""
        }
    }
}
