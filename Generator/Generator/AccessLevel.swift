//
//  AccessLevel.swift
//  Generator
//
//  Created by Kryštof Matěj on 16/02/2019.
//  Copyright © 2019 Kryštof Matěj. All rights reserved.
//

public enum AccessLevel {
    case `public`
    case `internal`
    case `private`

    func makeClassString() -> String {
        switch self {
        case .public:
            return "public "
        case .internal:
            return ""
        case .private:
            return "private "
        }
    }

    func makeContentString() -> String {
        switch self {
        case .public:
            return "public "
        case .internal, .private:
            return ""
        }
    }
}
