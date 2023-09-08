//
//  TypeStringFactory.swift
//  Generator
//
//  Created by Jan Halousek on 10.09.18.
//  Copyright © 2018 Kryštof Matěj. All rights reserved.
//

enum TypeStringFactory {
    static func makeSimpleString(_ type: TypeDeclaration) -> String {
        return "\(makeExistencial(for: type))\(type.name)\(type.isOptional ? "?" : "")"
    }

    private static func makeExistencial(for type: TypeDeclaration) -> String {
        if let existencial = type.existencial {
            return existencial + " "
        } else {
            return ""
        }
    }

    static func makeFunctionArgumentString(_ type: TypeDeclaration) -> String {
        var prefix = ""
        if let prefixValue = type.prefix {
            prefix = prefixValue.rawValue + " "
        }
        return prefix + makeSimpleString(type)
    }

    static func makeInitString(_ type: TypeDeclaration) -> String {
        var prefix = ""
        if type.isClosure && !type.isOptional {
            prefix = TypePrefix.escaping.rawValue + " "
        }
        return prefix + makeSimpleString(type)
    }
}
